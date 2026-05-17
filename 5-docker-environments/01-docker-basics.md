# Docker Basics: Containers, Images, and Dev Environments

Before we dive into running Bazel inside Docker, you need a solid foundation in Docker itself. If you already know Docker well, skim this page and jump to [02: Bazel Dev Container](Bazel-Dev-Container).

---

## What Problem Does Docker Solve?

You've built a Python app. It works perfectly on your laptop (Python 3.12, Ubuntu 24.04). You deploy it to the server (Python 3.9, Ubuntu 20.04). It crashes. Your colleague tries to run it on their Mac. Different version of an obscure library. It crashes differently.

This is the **"it works on my machine" problem**. Docker solves it by bundling your application *and its entire environment* into a single package called a **Container**.

---

## Core Concepts

### Image
A Docker **Image** is a read-only, layered filesystem snapshot. It contains:
- A base operating system (e.g., `ubuntu:24.04`, `debian:bookworm-slim`)
- System libraries installed via `apt`
- Language runtimes (Python, Go, Node.js)
- Your application code
- Configuration

Images are defined by a `Dockerfile` and built with `docker build`. They are immutable — you can't change a running container's image.

### Container
A **Container** is a running instance of an Image. If an image is a class, a container is an object. You can run many containers from the same image simultaneously.

Containers are:
- **Isolated** — they can't see other containers' processes or filesystems (by default)
- **Ephemeral** — when a container stops, any changes made inside it are lost (unless you use volumes)
- **Fast** — containers start in milliseconds, not minutes like VMs

### Volume
A **Volume** is how you persist data across container restarts, and how you mount your local development files *into* a container. This is the key mechanism for the Bazel dev container pattern:

```
Your laptop filesystem          Container filesystem
/home/uma/repos/my-project  →   /workspace/my-project
```

You edit files on your laptop. The container sees those same files instantly. You run Bazel inside the container. The build output is written back to your laptop's filesystem.

---

## The Dockerfile

A `Dockerfile` is a script of instructions to build an image, executed top to bottom.

```dockerfile
# Every image starts with a base
FROM ubuntu:24.04

# Avoid interactive prompts during package installs
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /workspace

# Copy files into the image (only if you're baking them into the image)
COPY requirements.txt .
RUN pip install -r requirements.txt

# The command that runs when the container starts
CMD ["bash"]
```

**Key instructions:**
| Instruction | Purpose |
|---|---|
| `FROM` | Sets the base image — always the first line |
| `RUN` | Executes a shell command during the build |
| `COPY` | Copies files from your local machine into the image |
| `WORKDIR` | Sets the working directory for subsequent commands |
| `ENV` | Sets an environment variable |
| `CMD` | Default command when container starts (can be overridden) |
| `ENTRYPOINT` | Like CMD but not overridable — use for containers that are "tools" |
| `EXPOSE` | Documents which port the container uses (informational only) |

### Layer Caching: The Most Important Docker Optimization

Each `RUN`, `COPY`, and `ADD` instruction creates a new layer. Docker caches layers — if an instruction and everything before it hasn't changed, Docker reuses the cached layer instead of re-running it.

**Bad (slow):** 
```dockerfile
COPY . /app          # Copies ALL your code — changes every time
RUN pip install -r requirements.txt  # Cache busted every time code changes!
```

**Good (fast):**
```dockerfile
COPY requirements.txt .   # Only changes when deps change
RUN pip install -r requirements.txt  # Cached until requirements.txt changes

COPY . /app               # Changes every time, but that's fine — deps are already installed
```

Always `COPY` dependency definition files and `RUN` installs **before** copying your application code.

---

## Multi-Stage Builds

For production images, you want the smallest possible image. Multi-stage builds let you use a large image to build, then copy only the artifact into a tiny final image:

```dockerfile
# Stage 1: Build (large image with all build tools)
FROM golang:1.22 AS builder
WORKDIR /build
COPY . .
RUN go build -o /app ./cmd/server

# Stage 2: Run (tiny image with just the binary)
FROM scratch
COPY --from=builder /app /app
CMD ["/app"]
```

The final image is only the Go binary — no compiler, no source code. This is how you get Docker images that are 10MB instead of 1GB.

---

## Essential Docker Commands

```bash
# Build an image from the Dockerfile in the current directory
docker build -t my-app:latest .

# Run a container interactively (drops you into a shell)
docker run -it my-app:latest bash

# Run a container with a volume mount (maps host path to container path)
docker run -it -v /home/uma/repos/my-project:/workspace my-app:latest bash

# Run a container with a port exposed
docker run -p 8080:8080 my-app:latest

# List running containers
docker ps

# Stop a running container
docker stop <container-id>

# List all images
docker images

# Remove an image
docker rmi my-app:latest

# Pull an image from Docker Hub
docker pull python:3.12-slim
```

---

## Docker Compose

Managing multiple containers with long `docker run` commands is painful. `docker-compose.yml` lets you define your entire environment declaratively:

```yaml
# docker-compose.yml
services:
  dev:
    build: .                              # Build from local Dockerfile
    volumes:
      - .:/workspace                      # Mount current dir into container
    working_dir: /workspace
    stdin_open: true
    tty: true

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: devpassword
    ports:
      - "5432:5432"
```

Now instead of a huge `docker run` command, you just:
```bash
# Start all services in the background
docker compose up -d

# Run a command inside the 'dev' service
docker compose run --rm dev bazel build //...

# Open a shell inside the 'dev' service
docker compose run --rm dev bash

# Stop everything
docker compose down
```

In the next page, we'll use exactly this pattern to build a full Bazel development container.
