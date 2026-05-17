# Worked Example: Multiple Python Versions in Docker + Bazel

This is the flagship tutorial. We will build a complete, runnable project from scratch where:

- Everything runs **inside a Docker container** (Bazel dev container pattern)
- A **legacy Python 3.10 service** and a **modern Python 3.12 service** coexist in the same repository
- **Bazel manages both Python interpreters** independently via `rules_python` toolchains — no pyenv, no virtualenvs, no manual version switching
- You can build and run both services with a single `bazel build //...`

By the end of this page, you will have a working project you can run on any machine with Docker installed.

---

## Project Overview

```
multi-python-demo/
├── .bazelversion
├── MODULE.bazel
├── MODULE.bazel.lock          ← (auto-generated)
├── .bazelrc
├── Dockerfile.dev
├── docker-compose.yml
├── Makefile
├── requirements_3_10.in       ← pip deps for the 3.10 service
├── requirements_3_10.lock     ← pinned lockfile for 3.10
├── requirements_3_12.in       ← pip deps for the 3.12 service
├── requirements_3_12.lock     ← pinned lockfile for 3.12
├── BUILD.bazel                ← Root BUILD file (pip update targets live here)
│
├── legacy-service/            ← Python 3.10 service
│   ├── BUILD.bazel
│   └── main.py
│
└── new-service/               ← Python 3.12 service
    ├── BUILD.bazel
    └── main.py
```

---

## Step 1: Create the Project Directory

```bash
mkdir multi-python-demo && cd multi-python-demo
git init
```

---

## Step 2: Pin the Bazel Version

```bash
echo "7.4.1" > .bazelversion
```

---

## Step 3: Write MODULE.bazel

This is the heart of the configuration. We register **both** Python toolchains and **two separate pip dependency sets** (one per Python version).

```python
# MODULE.bazel
module(
    name = "multi_python_demo",
    version = "0.1",
)

# ─── Python Rules ───────────────────────────────────────────────────────────
bazel_dep(name = "rules_python", version = "0.31.0")

python = use_extension("@rules_python//python/extensions:python.bzl", "python")

# Register Python 3.12 — this is the default for all py_* targets
python.toolchain(
    python_version = "3.12",
    is_default = True,
)

# Register Python 3.10 — for legacy-service
python.toolchain(
    python_version = "3.10",
    is_default = False,
)

# ─── Pip Dependencies (3.12) ─────────────────────────────────────────────────
pip_312 = use_extension("@rules_python//python/extensions:pip.bzl", "pip")
pip_312.parse(
    hub_name = "pip_312",
    python_version = "3.12",
    requirements_lock = "//:requirements_3_12.lock",
)
use_repo(pip_312, "pip_312")

# ─── Pip Dependencies (3.10) ─────────────────────────────────────────────────
pip_310 = use_extension("@rules_python//python/extensions:pip.bzl", "pip")
pip_310.parse(
    hub_name = "pip_310",
    python_version = "3.10",
    requirements_lock = "//:requirements_3_10.lock",
)
use_repo(pip_310, "pip_310")
```

---

## Step 4: Write .bazelrc

```
# .bazelrc

# Use local disk cache (mounted as a Docker volume for persistence)
build --disk_cache=/root/.cache/bazel

# Show test output on failures only
test --test_output=errors

# Use the modern Bzlmod dependency system
common --enable_bzlmod

# Ensure Python toolchain resolution is hermetic
build --incompatible_use_toolchain_resolution_for_py=true
```

---

## Step 5: Write the Root BUILD.bazel

The root `BUILD.bazel` file provides targets to **generate and update the pip lockfiles**. You run these any time you add or change a pip dependency.

```python
# BUILD.bazel
load("@rules_python//python:pip.bzl", "compile_pip_requirements")

# Run with: bazel run //:requirements_3_12.update
compile_pip_requirements(
    name = "requirements_3_12",
    src = "requirements_3_12.in",
    requirements_txt = "requirements_3_12.lock",
    python_version = "3.12",
)

# Run with: bazel run //:requirements_3_10.update
compile_pip_requirements(
    name = "requirements_3_10",
    src = "requirements_3_10.in",
    requirements_txt = "requirements_3_10.lock",
    python_version = "3.10",
)
```

---

## Step 6: Write the pip Requirements Files

```
# requirements_3_12.in
httpx>=0.27.0
```

```
# requirements_3_10.in
requests>=2.31.0
```

We're using different HTTP libraries intentionally — `httpx` (async-native, Python 3.12) vs `requests` (classic, Python 3.10) — to make the version separation obvious.

---

## Step 7: Write the Services

### `legacy-service/main.py` (Python 3.10 + requests)
```python
"""Legacy Service — runs on Python 3.10, uses the 'requests' library."""
import sys
import requests

def main():
    print(f"Legacy Service")
    print(f"Python version: {sys.version}")
    
    response = requests.get("https://httpbin.org/get", timeout=5)
    print(f"HTTP GET status: {response.status_code}")
    data = response.json()
    print(f"Origin IP: {data['origin']}")

if __name__ == "__main__":
    main()
```

### `legacy-service/BUILD.bazel`
```python
# legacy-service/BUILD.bazel
load("@rules_python//python:defs.bzl", "py_binary", "py_test")

py_binary(
    name = "legacy_service",
    srcs = ["main.py"],
    main = "main.py",
    python_version = "PY3",
    # Use the 3.10 toolchain
    deps = [
        "@pip_310//requests",
    ],
)
```

### `new-service/main.py` (Python 3.12 + httpx)
```python
"""New Service — runs on Python 3.12, uses the 'httpx' library."""
import sys
import httpx

def main():
    print(f"New Service")
    print(f"Python version: {sys.version}")
    
    with httpx.Client() as client:
        response = client.get("https://httpbin.org/get", timeout=5)
    print(f"HTTP GET status: {response.status_code}")
    data = response.json()
    print(f"Origin IP: {data['origin']}")

if __name__ == "__main__":
    main()
```

### `new-service/BUILD.bazel`
```python
# new-service/BUILD.bazel
load("@rules_python//python:defs.bzl", "py_binary")

py_binary(
    name = "new_service",
    srcs = ["main.py"],
    main = "main.py",
    python_version = "PY3",
    # Use the 3.12 toolchain (default)
    deps = [
        "@pip_312//httpx",
    ],
)
```

---

## Step 8: Write the Dockerfile

```dockerfile
# Dockerfile.dev
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    zip \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Bazelisk (auto-downloads correct Bazel version from .bazelversion)
RUN curl -Lo /usr/local/bin/bazel \
    https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel

WORKDIR /workspace
CMD ["bash"]
```

Note: we do **not** install Python in the Dockerfile. Bazel will download its own Python 3.10 and 3.12 interpreters via `rules_python`. The system Python is irrelevant.

---

## Step 9: Write docker-compose.yml and Makefile

```yaml
# docker-compose.yml
services:
  dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/workspace
      - bazel-cache:/root/.cache/bazel
    working_dir: /workspace
    stdin_open: true
    tty: true

volumes:
  bazel-cache:
```

```makefile
# Makefile
DOCKER_RUN := docker compose run --rm dev

.PHONY: build run-legacy run-new shell update-deps

build:
	$(DOCKER_RUN) bazel build //...

run-legacy:
	$(DOCKER_RUN) bazel run //legacy-service:legacy_service

run-new:
	$(DOCKER_RUN) bazel run //new-service:new_service

shell:
	docker compose run --rm dev bash

update-deps:
	$(DOCKER_RUN) bazel run //:requirements_3_10.update
	$(DOCKER_RUN) bazel run //:requirements_3_12.update
```

---

## Step 10: Generate the Lockfiles

Before you can build, you need to generate the pip lockfiles. This only needs to be done once, and again whenever you change `requirements_*.in`.

```bash
# Build the dev image first
docker compose build dev

# Generate lockfiles (Bazel will download the Python interpreters automatically)
docker compose run --rm dev bazel run //:requirements_3_10.update
docker compose run --rm dev bazel run //:requirements_3_12.update
```

This creates `requirements_3_10.lock` and `requirements_3_12.lock` — pinned, hash-verified files you commit to the repo.

---

## Step 11: Build and Run

```bash
# Build both services
make build

# Run the legacy service (Python 3.10 + requests)
make run-legacy
```

Expected output:
```
Legacy Service
Python version: 3.10.14 (main, Mar 25 2024, ...) [GCC 11.4.0]
HTTP GET status: 200
Origin IP: 1.2.3.4
```

```bash
# Run the new service (Python 3.12 + httpx)
make run-new
```

Expected output:
```
New Service
Python version: 3.12.3 (main, Apr  9 2024, ...) [GCC 11.4.0]
HTTP GET status: 200
Origin IP: 1.2.3.4
```

**Both services printed different Python versions.** Both ran inside the same Docker container. No `pyenv`, no `virtualenv`, no `conda`. Bazel downloaded and managed both interpreters completely transparently.

---

## Step 12: Commit Everything

```bash
git add .
git commit -m "feat: multi-python Bazel + Docker demo project"
gh repo create multi-python-demo --public --source=. --push
```

---

## Summary: What Just Happened?

| Concern | Who handles it |
|---|---|
| Consistent OS environment | Docker |
| Bazel binary version | Bazelisk + `.bazelversion` |
| Python 3.10 interpreter | `rules_python` toolchain (downloaded by Bazel) |
| Python 3.12 interpreter | `rules_python` toolchain (downloaded by Bazel) |
| pip packages for 3.10 | `pip_310` hub, pinned by `requirements_3_10.lock` |
| pip packages for 3.12 | `pip_312` hub, pinned by `requirements_3_12.lock` |
| Build orchestration | Bazel |
| Dev UX | `make` + `docker compose` |

Nothing is "installed" on the developer's machine except Docker. The entire toolchain — Bazel, Python 3.10, Python 3.12, and all pip packages — is managed by Bazel and cached in the `bazel-cache` Docker volume.
