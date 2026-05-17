# The Bazel Dev Container

The pattern we are building toward is this: **Docker wraps the environment, Bazel orchestrates the build inside it.** Your source code lives on your laptop. The build tools live in the container. You run Bazel inside the container against your source code mounted as a volume.

This gives you:
- Zero tool installation on developer laptops (just Docker)
- Identical build environments across all machines
- Bazel's hermetic, cached builds inside that consistent environment

---

## What Goes in the Dev Container Image?

The dev container image needs to contain everything required to **run Bazel** and to build your project, but NOT your source code (that's mounted at runtime).

At minimum:
- A base Linux OS (`ubuntu:24.04` is a great default)
- `curl`, `git`, `unzip` (utilities Bazel needs)
- The **Bazel** binary itself
- Any system-level build dependencies (e.g., `libssl-dev` for C++ projects, `python3` if not using Bazel-managed Python)
- Optional: your editor's language servers, debugging tools

---

## Step 1: Write the Dockerfile

Create `Dockerfile.dev` at the root of your project (we use a distinct name so it doesn't conflict with a production `Dockerfile`):

```dockerfile
# Dockerfile.dev
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV BAZEL_VERSION=7.4.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    zip \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Bazelisk (the Bazel version manager — preferred over installing Bazel directly)
# Bazelisk reads .bazelversion from your repo and downloads the correct Bazel version automatically
RUN curl -Lo /usr/local/bin/bazel \
    https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64 \
    && chmod +x /usr/local/bin/bazel

# Set the working directory where we'll mount the source code
WORKDIR /workspace

# Default to an interactive shell
CMD ["bash"]
```

**Why Bazelisk instead of Bazel directly?**  
Bazelisk reads a `.bazelversion` file in your repo root and automatically downloads and runs the exact Bazel version specified. This means all developers always use the same Bazel version, and upgrades are as simple as changing one file.

Create `.bazelversion` in your repo root:
```
7.4.1
```

---

## Step 2: Write docker-compose.yml

```yaml
# docker-compose.yml
services:
  dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    # Mount the entire repo into /workspace inside the container
    volumes:
      - .:/workspace
      # Mount a named volume for the Bazel cache — persists between container restarts
      # so you don't have to rebuild everything every time you restart the container
      - bazel-cache:/root/.cache/bazel
    working_dir: /workspace
    # Keep the container alive for interactive use
    stdin_open: true
    tty: true
    # Pass your git config into the container
    environment:
      - GIT_AUTHOR_NAME
      - GIT_AUTHOR_EMAIL

volumes:
  bazel-cache:
```

The `bazel-cache` named volume is critical. Without it, every time you restart your container, Bazel starts from scratch. The cache can be gigabytes for a large project. You want it to persist.

---

## Step 3: Build the Image

```bash
# Build the dev image (only needed once, or when Dockerfile.dev changes)
docker compose build dev
```

This will take a few minutes the first time. After that, it's instant (Docker layer cache).

---

## Step 4: Run Bazel Inside the Container

Now you have two ways to use the container:

### Option A: Interactive Shell (most common for development)
```bash
# Drop into a shell inside the container
docker compose run --rm dev bash

# Now you're inside the container — run Bazel commands as normal:
bazel build //...
bazel test //...
bazel run //api:server
```

You'll notice the shell prompt changes to indicate you're inside the container. Your files in `/workspace` are your actual laptop files — any edits you make in your editor on the laptop appear instantly inside the container.

### Option B: One-off Commands (good for CI or scripts)
```bash
# Run a single command inside the container without entering a shell
docker compose run --rm dev bazel build //...
docker compose run --rm dev bazel test //api/...
```

### Option C: Make Targets (recommended for teams)
Add a `Makefile` so nobody needs to remember the full `docker compose` command:

```makefile
# Makefile
DOCKER_RUN = docker compose run --rm dev

.PHONY: build test shell

build:
	$(DOCKER_RUN) bazel build //...

test:
	$(DOCKER_RUN) bazel test //...

shell:
	docker compose run --rm dev bash
```

Now the team just runs:
```bash
make build
make test
make shell
```

---

## Step 5: Verify It Works

Let's do a full end-to-end check. Assuming you have at least a `MODULE.bazel` at the root:

```bash
# On your laptop:
docker compose run --rm dev bash

# Inside the container:
bazel version
# Should print the version from .bazelversion (e.g., 7.4.1)

bazel build //...
# Should build your project

exit
```

---

## Troubleshooting

### "Permission denied" on build outputs
Bazel inside the container runs as root. Files it creates in `bazel-out/` may be owned by root, making them hard to delete from your laptop. Add this to `.gitignore`:
```
bazel-out/
bazel-bin/
```
And to clean: `docker compose run --rm dev bazel clean`.

### "Out of disk space" for the Bazel cache
The Bazel cache grows without bound. Periodically:
```bash
docker volume rm <project>_bazel-cache
```
Or configure a max cache size in `.bazelrc`:
```
build --disk_cache=/root/.cache/bazel
```

### Container is slow on Mac
Docker on Mac runs inside a Linux VM, and volume mounts across the VM boundary are slow. Use [Docker Desktop's VirtioFS](https://docs.docker.com/desktop/settings/mac/#file-sharing) for much better performance.
