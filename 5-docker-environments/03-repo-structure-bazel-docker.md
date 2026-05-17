# Repo Structure for Bazel + Docker Projects

Now that we understand both Bazel and Docker independently, let's look at how to organize a repository that uses both together. Good structure here makes the project easy to build, test, and onboard into — for both humans and AI agents.

---

## The Canonical Layout

```
my-project/
│
├── .bazelversion              ← Pins the exact Bazel version (read by Bazelisk)
├── MODULE.bazel               ← Bazel module definition & external dependencies
├── MODULE.bazel.lock          ← Lockfile for reproducible dependency resolution
├── .bazelrc                   ← Persistent Bazel CLI flags for the project
│
├── Dockerfile.dev             ← Dev environment image (contains Bazel, build tools)
├── docker-compose.yml         ← Orchestrates dev container(s)
├── Makefile                   ← Convenience wrappers: `make build`, `make test`, `make shell`
│
├── AGENTS.md                  ← Agent instructions (include Docker/Bazel commands!)
├── ARCHITECTURE.md            ← How the system fits together
├── README.md                  ← Human-facing: how to get started
│
├── api/                       ← Go REST API service
│   ├── BUILD.bazel
│   ├── main.go
│   └── handlers/
│       ├── BUILD.bazel
│       ├── user_handler.go
│       └── user_handler_test.go
│
├── ml-service/                ← Python ML service
│   ├── BUILD.bazel
│   ├── service.py
│   └── tests/
│       └── test_service.py
│
├── tools/                     ← Bazel-managed developer tools (linters, formatters, code generators)
│   ├── BUILD.bazel
│   └── format.sh
│
└── deploy/                    ← Production Docker image definitions (built by Bazel)
    ├── BUILD.bazel
    └── api.Dockerfile
```

---

## File-by-File Breakdown

### `.bazelversion`
```
7.4.1
```
Pins the Bazel version. Bazelisk reads this and downloads the correct binary. Always commit this file.

### `MODULE.bazel`
The root of the Bazel dependency graph. Declares external dependencies using Bazel's module system (Bzlmod):

```python
module(
    name = "my_project",
    version = "0.1",
)

# Go rules
bazel_dep(name = "rules_go", version = "0.46.0")
bazel_dep(name = "gazelle", version = "0.35.0")

# Python rules
bazel_dep(name = "rules_python", version = "0.31.0")

# OCI/Docker image rules
bazel_dep(name = "rules_oci", version = "1.7.4")
```

### `.bazelrc`
Persistent flags that apply to every `bazel` invocation. This file is committed to the repo:

```
# Use the disk cache (persistent across container restarts via volume mount)
build --disk_cache=/root/.cache/bazel

# Show test output for failures
test --test_output=errors

# Always use hermetic Python toolchain (don't use system Python)
build --incompatible_use_toolchain_resolution_for_py=true

# Enable Bzlmod (the modern dependency system)
common --enable_bzlmod
```

### `Dockerfile.dev`
The developer environment image. Contains Bazel (via Bazelisk), all system build dependencies, and nothing else. Source code is volume-mounted at runtime, not baked into the image.

See [02: Bazel Dev Container](Bazel-Dev-Container) for the full Dockerfile.

### `docker-compose.yml`
Orchestrates the dev container. Key features:
- Mounts the repo root into `/workspace` in the container
- Mounts a named volume for the Bazel cache (so it persists between restarts)
- Optionally starts a database or other services alongside the dev container

### `Makefile`
Simple wrappers so engineers don't need to memorize Docker and Bazel commands:

```makefile
DOCKER_RUN := docker compose run --rm dev

.PHONY: build test shell clean fmt

build:
	$(DOCKER_RUN) bazel build //...

test:
	$(DOCKER_RUN) bazel test //...

shell:
	docker compose run --rm dev bash

clean:
	$(DOCKER_RUN) bazel clean

fmt:
	$(DOCKER_RUN) bash tools/format.sh
```

### `BUILD.bazel` Files
Every directory that Bazel should know about needs a `BUILD.bazel` file. At a minimum, each `BUILD.bazel` declares the targets in that package:

```python
# api/handlers/BUILD.bazel
load("@rules_go//go:def.bzl", "go_library", "go_test")

go_library(
    name = "handlers",
    srcs = glob(["*.go"], exclude = ["*_test.go"]),
    importpath = "github.com/myorg/my-project/api/handlers",
    deps = [
        "//api/models",
        "//api/db",
    ],
)

go_test(
    name = "handlers_test",
    srcs = glob(["*_test.go"]),
    embed = [":handlers"],
)
```

### `deploy/` Directory
For production deployments, you build Docker images using Bazel (via `rules_oci`). The `deploy/` directory contains the `BUILD.bazel` targets that define your production images. These are built and pushed by CI, not by developers locally.

---

## Getting Started Checklist

When setting up a brand-new project with this structure:

```bash
# 1. Create the directory
mkdir my-project && cd my-project

# 2. Create the Bazel version file
echo "7.4.1" > .bazelversion

# 3. Create MODULE.bazel
touch MODULE.bazel

# 4. Create .bazelrc with sensible defaults
cat > .bazelrc << 'EOF'
build --disk_cache=/root/.cache/bazel
test --test_output=errors
common --enable_bzlmod
EOF

# 5. Create the dev Dockerfile
# (see previous page for full contents)
touch Dockerfile.dev

# 6. Create docker-compose.yml
touch docker-compose.yml

# 7. Build the dev image
docker compose build dev

# 8. Verify Bazel works inside the container
docker compose run --rm dev bazel version

# 9. Initialize git and make your first commit
git init
git add .
git commit -m "chore: initial project structure with Bazel + Docker"
```
