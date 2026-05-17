# What is Bazel?

As codebases grow from small scripts to massive applications with hundreds of dependencies across multiple languages, standard build tools (like Make, npm, or Maven) start to struggle. Builds become slow, flaky, and hard to manage.

This is where **Bazel** comes in.

## The Origin of Bazel
Bazel is the open-source version of Google's internal build system, "Blaze." Google engineers needed a way to build a repository containing millions of lines of code quickly and reliably. Bazel was designed specifically to solve this problem of scale.

## Core Concepts

### 1. Fast (Caching and Parallelism)
Bazel is fast because it caches all previously done work. If you change one file, Bazel only rebuilds that file and the things that depend directly on it. Furthermore, it runs independent build steps in parallel.

### 2. Correct (Hermeticity)
Have you ever heard the excuse, *"But it works on my machine!"*? 
Bazel aims to eliminate this by being **Hermetic**. A hermetic build means that if the source code and the `BUILD` files are the same, the output will be exactly the same, no matter what machine it runs on. It isolates the build from the host environment's installed libraries or global variables.

### 3. Multi-Language Support
Instead of using `npm` for the frontend, `maven` for the Java backend, and `pip` for Python scripts, Bazel can build all of them within a single unified system. You declare rules for different languages, and Bazel orchestrates everything.

### 4. Scalability
Bazel shines in "monorepos"—giant repositories containing code for many different projects and services. It allows teams to share code easily while keeping build times incredibly low.

## The Terminology
- **Workspace:** A directory containing all your source code and a special `WORKSPACE` or `MODULE.bazel` file at the root.
- **Packages:** A directory containing a `BUILD.bazel` file. It groups related files together.
- **Targets:** Things to be built (e.g., a binary, a library, a test).
- **Rules:** The instructions that tell Bazel *how* to build a target (e.g., `cc_binary` to build a C++ executable, `ts_library` to compile TypeScript).

## When Should You Use Bazel?
Bazel is incredibly powerful, but it has a steep learning curve.
- **Use Bazel if:** You have a very large codebase, a monorepo, use multiple programming languages, or are experiencing painfully slow build times.
- **Don't use Bazel if:** You are building a simple, single-language project (like a standard Next.js app or a basic Python script). Standard tools are much easier to set up for small projects.

In the next section, we'll look at what a basic Bazel workspace looks like.
