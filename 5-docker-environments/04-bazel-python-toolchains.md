# Bazel Python Toolchains

One of Bazel's most powerful features — and one of its most misunderstood — is **toolchains**. For Python developers, toolchains are the key to running multiple Python versions in a single project, completely isolated from the system Python.

---

## What Is a Toolchain?

In Bazel, a **toolchain** is a set of rules that tells Bazel *how to use a specific tool* to perform a build action.

For Python, a toolchain tells Bazel:
- Where to find the Python interpreter
- What version it is
- What platform it runs on

When you write a `py_binary` or `py_test` in a `BUILD.bazel` file, you don't specify which Python interpreter to use. Bazel consults the registered toolchains, finds the one that matches the current platform and any constraints you specify, and uses that one.

---

## The Problem with System Python

Without Bazel toolchains, Python builds rely on whatever `python3` is on `$PATH` in the environment. This causes:
- **Version mismatch**: CI has Python 3.9. Your laptop has 3.12. Subtle incompatibilities.
- **Library pollution**: A globally installed package might shadow one of your dependencies.
- **Non-reproducibility**: Two machines with different system Pythons produce different results.

With Bazel's `rules_python` toolchains, Bazel **downloads and manages its own Python interpreter** — completely independently of whatever is installed on the system. The system Python becomes irrelevant.

---

## Setting Up `rules_python` in MODULE.bazel

`rules_python` is the official Bazel ruleset for Python. It provides `py_binary`, `py_library`, `py_test`, and crucially, hermetic Python toolchain registration.

### Step 1: Declare the dependency in `MODULE.bazel`

```python
# MODULE.bazel
module(
    name = "my_project",
    version = "0.1",
)

bazel_dep(name = "rules_python", version = "0.31.0")
```

### Step 2: Register a Python toolchain

```python
# MODULE.bazel (continued)

python = use_extension("@rules_python//python/extensions:python.bzl", "python")

# Register Python 3.12 as a toolchain
python.toolchain(
    python_version = "3.12",
    is_default = True,  # Used when no specific version is requested
)
```

That's it. When you run `bazel build //...`, Bazel will download a pre-built CPython 3.12 interpreter for your platform (Linux x86_64, Mac arm64, etc.) and use it for all Python targets.

---

## Using the Toolchain in BUILD.bazel

Once registered, using it is simple. You write `py_binary`, `py_library`, and `py_test` targets exactly as before — no special annotation needed for the default version:

```python
# my-service/BUILD.bazel
load("@rules_python//python:defs.bzl", "py_binary", "py_test")

py_binary(
    name = "service",
    srcs = ["service.py"],
    deps = [
        # pip-managed dependencies go here
        "@pip//requests",
        "@pip//flask",
    ],
)

py_test(
    name = "service_test",
    srcs = ["tests/test_service.py"],
    deps = [":service"],
)
```

---

## Managing pip Dependencies with Bazel

You don't use `pip install` manually with Bazel. Instead, you declare your pip dependencies inside `MODULE.bazel` and Bazel resolves them:

```python
# MODULE.bazel

pip = use_extension("@rules_python//python/extensions:pip.bzl", "pip")

pip.parse(
    hub_name = "pip",            # The name you reference in deps as "@pip//"
    python_version = "3.12",
    requirements_lock = "//:requirements_3_12.lock",
)
use_repo(pip, "pip")
```

Then you maintain a `requirements_3_12.lock` file (a pinned, hash-verified requirements file):

```bash
# Generate the lockfile:
bazel run //:requirements_3_12.update
```

This gives you fully reproducible pip installs — the exact same packages, the same versions, on every machine.

---

## Multiple Python Versions: The Key Insight

The power of Bazel toolchains really shows when you need **two different Python versions in the same repository** — e.g., a legacy service that must stay on Python 3.10 and a new service using Python 3.12.

You register both toolchains in `MODULE.bazel`:

```python
python.toolchain(
    python_version = "3.12",
    is_default = True,
)

python.toolchain(
    python_version = "3.10",
    is_default = False,
)
```

And in your `BUILD.bazel`, you can specify which version a target should use:

```python
load("@rules_python//python:defs.bzl", "py_binary")

# This target uses Python 3.10
py_binary(
    name = "legacy_service",
    srcs = ["legacy_service.py"],
    python_version = "PY3",
    # Specify the toolchain explicitly
    exec_compatible_with = [],
    toolchains = ["@rules_python//python/cc:current_py_cc_toolchain"],
)
```

The cleanest way to specify versions per target uses `python_version` constraints. The next page has the **complete worked example** that puts all of this together.

---

## Key Commands

```bash
# Inside the dev container:

# Build all Python targets (uses default Python version)
bazel build //...

# Run a specific Python binary
bazel run //ml-service:service

# Run Python tests
bazel test //ml-service:service_test

# Update pip lockfile (run this after changing requirements.txt)
bazel run //:requirements_3_12.update

# Query which toolchain will be used for a target
bazel query --output=build //ml-service:service
```
