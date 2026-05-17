# Structuring a Repo for Agents

AI Agents are incredibly smart, but they are still software. Just as human engineers appreciate a well-organized codebase, AI agents perform significantly better when a repository is structured logically and contains the right kind of context.

## The Problem with "Spaghetti" Repos
If your codebase has no consistent architecture, mixes concerns, and lacks documentation, an agent will struggle. It will waste tokens (which cost money and time) trying to figure out where things are, and it's more likely to make mistakes.

## Key Principles for Agent-Friendly Repositories

### 1. Predictable Directory Structures
Use standard directory structures for your chosen language/framework. Do not invent your own novel folder layout unless absolutely necessary.
- If it's a Go project, follow the standard Go project layout (`cmd/`, `pkg/`, `internal/`).
- If it's a React/Next.js app, stick to conventional routing and `components/` folders.
- Agents are trained on millions of public repos. If yours looks like those repos, the agent already knows how to navigate it.

### 2. High-Quality Documentation
Agents read documentation much faster and more reliably than they infer complex code logic.
- **README.md:** Keep it up to date. Include instructions on how to build, test, and run the project.
- **ARCHITECTURE.md:** A high-level overview of how the system components interact.
- **Docstrings and Comments:** Explain *why* a complex piece of code exists, not just *what* it does. If a piece of code works around a weird bug, document the bug. The agent needs to know not to accidentally "fix" your workaround.

### 3. Clear Interfaces and Boundaries
Agents excel at tasks that are well-scoped. If your code is tightly coupled, a small change requested by an agent might cascade and break the entire system.
- Use interfaces and abstract classes.
- Keep functions small and focused on a single responsibility (SOLID principles).
- This allows you to ask the agent to "Implement the `DatabaseInterface` for Postgres," and the agent knows exactly where the boundaries of its task lie.

### 4. Provide "Rules" or "Guidelines" Files
You can include specific files in your repository that explicitly tell the agent how to behave.
- e.g., a `prompt.txt` or `.cursorrules` file at the root of the project.
- You can include instructions like:
  - "Always use functional components in React."
  - "Never use Tailwind CSS, we only use Vanilla CSS."
  - "When adding a new database model, always create a corresponding migration file."
- Agents will often look for or can be directed to these files for context before starting a task.

### 5. Robust Test Suites
The best way for an agent to know it succeeded is if it can run a test and get a green checkmark.
- Maintain a comprehensive suite of unit and integration tests.
- Provide a single, easy command to run all tests (e.g., `make test` or `bazel test //...`). The agent can use its terminal tool to run this and verify its own work.

By designing your repository with the agent in mind, you transform it from a challenging puzzle into an efficient workspace where the AI can thrive.
