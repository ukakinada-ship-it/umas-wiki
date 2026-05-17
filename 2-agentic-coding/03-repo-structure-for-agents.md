# Structuring a Repository for Agents

The way you organize your repository has a massive impact on how effectively an AI agent can work within it. A well-structured repo lets an agent navigate, understand, and make correct changes on the first try. A poorly structured repo forces the agent to make assumptions — and assumptions lead to bugs.

---

## The Core Principle: Predictability Over Cleverness

Agents are trained on millions of public repositories. They have deep knowledge of **conventional** patterns — the standard Go project layout, Next.js app router structure, Python package layouts. If your repo follows these conventions, the agent already knows where everything lives.

Clever, custom organizational schemes force the agent to rediscover your architecture every single time.

> **Rule of thumb:** If a new human engineer couldn't navigate your repo in 5 minutes, an agent will struggle too.

---

## The Ideal Repository Layout

Here's a worked example of an agent-friendly monorepo containing a Go API backend and a Python ML service:

```
my-project/
│
├── AGENTS.md                  ← The most important file for agents (see next page)
├── ARCHITECTURE.md            ← High-level system diagram and component overview
├── README.md                  ← How to build, run, and test the project
│
├── MODULE.bazel               ← Bazel module definition (if using Bazel)
├── .bazelrc                   ← Bazel CLI flags and build options
│
├── Dockerfile                 ← Dev environment Docker image
├── docker-compose.yml         ← Starts all services together
│
├── api/                       ← Go REST API service
│   ├── BUILD.bazel
│   ├── main.go
│   ├── handlers/
│   │   ├── BUILD.bazel
│   │   ├── user_handler.go
│   │   └── user_handler_test.go
│   ├── models/
│   │   ├── BUILD.bazel
│   │   └── user.go
│   └── middleware/
│       ├── BUILD.bazel
│       └── auth.go
│
├── ml-service/                ← Python ML inference service
│   ├── BUILD.bazel
│   ├── requirements.txt
│   ├── service.py
│   └── tests/
│       └── test_service.py
│
├── docs/                      ← Human documentation
│   └── api-spec.yaml
│
└── tools/                     ← Dev scripts (linting, formatting, code gen)
    └── format.sh
```

### Why this works for agents:
- **One concern per directory** — `api/handlers/` contains only handlers
- **Test files live next to source files** — the agent knows where to add tests
- **`BUILD.bazel` in every package** — Bazel dependencies are explicit and local
- **`AGENTS.md` at root** — the agent reads this first for conventions
- **`ARCHITECTURE.md` at root** — gives the agent the big picture before diving into code

---

## The ARCHITECTURE.md File

Every agent-friendly repo should have an `ARCHITECTURE.md`. It answers the question: *"How do the pieces fit together?"* before the agent reads a single line of code.

Here's a real-world example:

```markdown
# Architecture Overview

## System Components

┌─────────────────┐     HTTP      ┌──────────────────┐
│   React Frontend │ ──────────► │   Go REST API     │
└─────────────────┘             └──────────┬───────-─┘
                                           │ gRPC
                                ┌──────────▼──────────┐
                                │  Python ML Service   │
                                └──────────┬──────────┘
                                           │
                                ┌──────────▼──────────┐
                                │   PostgreSQL DB       │
                                └─────────────────────┘

## Data Flow
1. User submits a form in the React frontend.
2. Frontend POSTs to `POST /api/predictions`.
3. Go API validates the request, writes a job to the DB.
4. Go API calls the Python ML service via gRPC to get a prediction.
5. ML service runs the model and returns a score.
6. Go API writes the result to DB and returns it to the frontend.

## Key Conventions
- All API handlers live in `api/handlers/`. One file per resource.
- The ML model files (.pkl) are stored in `ml-service/models/` and are NOT committed to git (see .gitignore).
- Database migrations use Alembic. Never modify DB schema directly.
```

When an agent reads this before starting a task, it immediately understands the system without having to infer it from code. This prevents it from, say, directly querying the database from the API layer when it should be going through the ML service.

---

## Coding Conventions: Make Them Explicit

Agents infer conventions from the existing code, but they can get it wrong if your codebase is inconsistent. Make conventions explicit in `AGENTS.md` (covered in depth next page), and also enforce them with tooling:

- **Linters** (`golangci-lint`, `ruff`, `eslint`) — the agent can run these and self-correct
- **Formatters** (`gofmt`, `black`, `prettier`) — the agent should run these before committing
- **Type checkers** (`mypy`, `tsc --noEmit`) — catches type errors the agent might introduce

Add a single `make lint` or `bazel test //tools/...` command that runs all of these. Tell the agent to run it before calling a task done.

---

## Keep Functions Small and Focused

Agents produce better results when they work with small, well-scoped functions. A 500-line function with complex branching logic is hard for any developer (human or AI) to modify safely.

If you ask an agent to modify a 500-line function, it has to understand the entire function before touching it. If you have 20 small functions, it can identify and modify exactly the one it needs.

**Before (hard for agents):**
```python
def process_order(order_data):
    # 500 lines mixing validation, DB writes, email sending,
    # payment processing, inventory management, and logging
    ...
```

**After (agent-friendly):**
```python
def process_order(order_data):
    validated = validate_order(order_data)
    charge_result = process_payment(validated)
    inventory = reserve_inventory(validated)
    record = save_order_to_db(validated, charge_result, inventory)
    send_confirmation_email(record)
    log_order_event(record)
    return record
```

The agent can now be asked to "modify how payment processing works" and knows *exactly* which function to touch.
