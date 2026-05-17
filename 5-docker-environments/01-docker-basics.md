# Docker Basics

In the section on Bazel, we talked about "Hermeticity"—the idea that a build should act the same everywhere. But what if the code runs perfectly on your laptop, but crashes when you deploy it to a server because the server is running a different version of Linux?

**Docker** solves the "It works on my machine!" deployment problem.

## What is Docker?
Docker is a platform that allows you to package an application and all its dependencies into a standardized unit called a **Container**.

### Containers vs. Virtual Machines
A Virtual Machine (VM) runs a full, separate operating system (OS) on top of your computer's OS. This is slow and takes up gigabytes of RAM and disk space.

A Container shares the host's OS kernel but isolates the application processes. Containers start in milliseconds and use very little memory. You can easily run dozens of containers on a standard laptop.

## Key Docker Concepts

1. **Dockerfile:** A simple text file that contains the instructions to build an image. It's the "recipe."
2. **Image:** A read-only template created from a Dockerfile. It contains the OS libraries, tools, and your code. It's the "compiled binary" of the Docker world.
3. **Container:** A running instance of an Image. If an image is a class, a container is an object instantiated from that class.

## The Docker Workflow

### 1. The Dockerfile
Let's say you have a simple Python web server. You create a `Dockerfile`:

```dockerfile
# Start from a lightweight Python base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy your code into the container
COPY . /app

# Install dependencies
RUN pip install -r requirements.txt

# Tell Docker what command to run when the container starts
CMD ["python", "server.py"]
```

### 2. Build the Image
You run this command in the terminal to build the image and tag it with a name:
```bash
docker build -t my-python-app .
```

### 3. Run the Container
Now you can start a container based on that image:
```bash
docker run -p 8080:80 my-python-app
```
*(This maps port 8080 on your laptop to port 80 inside the container).*

## Why is this so powerful?
Because you can take that exact same `my-python-app` image, put it on an AWS server, a Raspberry Pi, or your coworker's laptop, and it will run **exactly identically**. It brings its own environment with it.

In the next section, we'll see how we can combine Docker with Bazel to create the ultimate development environment.
