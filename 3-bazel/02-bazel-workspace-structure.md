# Bazel Workspace Structure

To use Bazel, you need to organize your repository in a specific way. Let's walk through the essential files that make up a Bazel workspace.

## The Root: `WORKSPACE` (or `MODULE.bazel`)
At the very root of your project, you must have a file named `WORKSPACE` (or in newer Bazel versions, `MODULE.bazel` for Bzlmod). 

This file does two things:
1. It tells Bazel, "This directory is the root of the project."
2. It fetches external dependencies (like third-party libraries from GitHub or package registries).

*Example `WORKSPACE`:*
```python
# Fetches the rules for building Python
http_archive(
    name = "rules_python",
    sha256 = "...",
    strip_prefix = "rules_python-0.5.0",
    urls = ["https://github.com/bazelbuild/rules_python/archive/0.5.0.tar.gz"],
)
```

## The Packages: `BUILD.bazel`
Inside your workspace, you group your code into "Packages." A package is simply any directory that contains a file named `BUILD` or `BUILD.bazel`.

The `BUILD` file tells Bazel what the "targets" are in this directory.

*Example structure:*
```text
my-workspace/
├── WORKSPACE
└── src/
    └── greeting/
        ├── BUILD.bazel
        ├── hello.py
        └── hello_test.py
```

## Inside a `BUILD.bazel` File
In the `src/greeting/BUILD.bazel` file, you use Bazel "Rules" to define your targets:

```python
# We are using Python rules
load("@rules_python//python:defs.bzl", "py_binary", "py_test")

# Target 1: A binary (an executable program)
py_binary(
    name = "hello",
    srcs = ["hello.py"],
)

# Target 2: A test
py_test(
    name = "hello_test",
    srcs = ["hello_test.py"],
    deps = [":hello"], # This test depends on the "hello" target
)
```

## Running Bazel Commands
Once your workspace and build files are set up, you use the `bazel` CLI tool to build or run your targets.

Targets are referenced by their "Label", which looks like `//path/to/package:target_name`.

1. **Build a target:**
   ```bash
   bazel build //src/greeting:hello
   ```
2. **Run a target:**
   ```bash
   bazel run //src/greeting:hello
   ```
3. **Run tests:**
   ```bash
   bazel test //src/greeting:hello_test
   ```
4. **Build the entire workspace:**
   ```bash
   bazel build //...
   ```

## The "bazel-bin" Output
When you run a build, Bazel doesn't litter your source directories with compiled files. Instead, it creates hidden symlinked directories at the root of your workspace (e.g., `bazel-bin`, `bazel-out`). 

If you build an executable, you'll find the finished, runnable artifact inside the `bazel-bin` directory.

Understanding this structure is key to migrating any project to Bazel. In the Docker section later, we'll see how Bazel and Docker combine to create the ultimate reproducible environment.
