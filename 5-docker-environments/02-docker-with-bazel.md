# Docker and Bazel: The Ultimate Dev Environment

We know Bazel makes builds fast and hermetic. We know Docker makes runtime environments consistent. Combining them creates an engineering superpower: **Reproducible Development Environments**.

## The Problem with Onboarding
Usually, when a new engineer joins a team, their first three days are spent installing specific versions of Java, Python, Node.js, C++ compilers, and database drivers. If they install the wrong version of one thing, the codebase won't build.

## The Solution: Dev Containers
Instead of installing all these tools directly on the engineer's laptop, we put all the build tools (including Bazel) inside a Docker Container. The engineer mounts the source code into this container and runs all their commands from *inside* the container.

### How it works
1. **The Base Image:** The team maintains a heavy Docker image containing Bazel, the exact right C++ compiler, the correct Python version, etc.
2. **The Mount:** The developer opens their terminal and runs a command to start the container, mounting their local repository directory into it.
3. **The Build:** The developer types `bazel build //...` inside the container. Bazel uses the tools installed in the container to build the code.

### The Benefits
- **Zero Install:** The only thing a new developer needs to install is Docker.
- **Perfect Consistency:** Everyone on the team is using the exact same compiler version, preventing "works on my machine" bugs.
- **Easy Upgrades:** Need to upgrade from Python 3.9 to 3.10? Update the Dockerfile, push the new image, and the whole team is instantly upgraded the next time they start their container.

## Building Docker Images *with* Bazel
Bazel can also be used to *build* Docker images, bypassing the need for `Dockerfile`s entirely!

Using rules like `rules_oci` or `rules_docker`, you can tell Bazel to take the binary it just compiled and package it directly into a lightweight Docker image.

```python
load("@rules_oci//oci:defs.bzl", "oci_image")

oci_image(
    name = "my_app_image",
    base = "@ubuntu_base_image", # A base image fetched in the WORKSPACE
    entrypoint = ["/my_app_binary"],
    tars = [":my_app_tar"], # The compiled code packed into a tarball
)
```

**Why do this?**
Because Bazel is smart. If you change a single line of Python code, Bazel knows it only needs to update that specific layer of the Docker image. It doesn't have to rebuild the entire image from scratch like a standard `docker build` command would. This makes iterating on containerized applications blazingly fast.

## Summary
By using Docker to standardize the environment and Bazel to orchestrate the build, you create a highly scalable, robust engineering culture that is perfectly suited for both human developers and AI Agents.
