# The AGENTS.md File: A Deep Dive

`AGENTS.md` is the single most impactful file you can add to any repository for agentic coding. It is a document written *for the agent* (not for human developers), placed at the root of the repo. It tells the agent the critical project-specific context it cannot infer from code alone.

Without `AGENTS.md`, the agent has to guess at your conventions, test commands, and gotchas every single time — often getting them wrong.

---

## The Six Sections of a Great AGENTS.md

### 1. Tech Stack
List every major technology in the project. Be specific about versions.

### 2. How to Build
The exact commands to build the project from scratch.

### 3. How to Test
The exact commands to run tests — all of them, and specific subsets.

### 4. Code Conventions
The rules that are not enforced by a linter but that the team follows consistently.

### 5. Gotchas & Warnings
The non-obvious things that will trip up someone unfamiliar with the repo.

### 6. What NOT to Do
Explicit prohibitions. Things that look reasonable but are wrong for this project.

---

## A Fully Worked Example

Here is a complete, production-quality `AGENTS.md` for a real-world web application:

```markdown
# AGENTS.md

This file provides context for AI agents (e.g. Antigravity) working in this repository.
Read this file before starting any task.

## Tech Stack

- **Backend:** Go 1.22 (REST API, using the `chi` router)
- **Frontend:** Next.js 14 (App Router, TypeScript, Tailwind CSS)
- **Database:** PostgreSQL 15 (via `pgx/v5` driver, NOT `database/sql`)
- **ORM:** None — we write raw SQL. Queries live in `api/db/queries/`.
- **Migrations:** golang-migrate (`migrate` CLI). Migration files in `api/db/migrations/`.
- **Build System:** Bazel 7.x
- **Containerization:** Docker + Docker Compose
- **CI:** GitHub Actions (`.github/workflows/`)
- **Testing (Go):** standard `testing` package + `testify` for assertions
- **Testing (TS):** Vitest for unit tests, Playwright for E2E

## How to Build

> All commands should be run inside the dev container: `docker compose run --rm dev bash`

```bash
# Build everything
bazel build //...

# Build only the API
bazel build //api:server

# Build only the frontend
bazel build //frontend:next

# Build the production Docker image
bazel build //deploy:image
```

## How to Test

```bash
# Run all tests
bazel test //...

# Run only backend tests
bazel test //api/...

# Run only frontend unit tests
bazel test //frontend/...

# Run a single specific test
bazel test //api/handlers:user_handler_test

# Run E2E tests (requires the full stack to be running)
docker compose up -d
bazel test //e2e:playwright_tests
```

## Code Conventions

### Go (Backend)
- One handler per HTTP resource. `user_handler.go` contains ALL user-related endpoints.
- Handler functions are named `{Verb}{Resource}Handler`, e.g. `CreateUserHandler`, `ListUsersHandler`.
- All DB queries go in `api/db/queries/`. NEVER write SQL inline in a handler.
- Errors are wrapped with `fmt.Errorf("context: %w", err)` — never just returned bare.
- Log with `slog` (NOT `log`, NOT `fmt.Println`). Always include structured fields.
- Return JSON errors as `{"error": "human readable message"}`. Never expose internal error details.

### TypeScript (Frontend)
- Use server components by default. Only use `"use client"` when you absolutely need interactivity.
- All API calls go through `src/lib/api.ts` — never `fetch()` directly from a component.
- Use `zod` for all data validation — on both the client (form validation) and server (API response parsing).
- CSS: Tailwind only. No inline styles. No CSS modules. No plain CSS files.

### General
- Commit messages: Conventional Commits format (`feat:`, `fix:`, `chore:`, `docs:`, etc.)
- Branch names: `{type}/{short-description}`, e.g. `feat/user-auth`, `fix/login-500-error`

## Gotchas & Warnings

- **NEVER use `database/sql` directly.** We use `pgx/v5` which has a different API. If you see `db.QueryRow()`, that's the pgx way, not the stdlib way.
- **The frontend runs on port 3000, the API on port 8080.** The frontend proxies `/api/*` to the backend. Do not hardcode `localhost:8080` in the frontend — use `/api/`.
- **Bazel caches aggressively.** If a test is passing locally but CI is failing, try `bazel clean --expunge` before debugging further.
- **Migrations are irreversible in production.** Always write both an `up` and `down` migration. Name them descriptively: `001_add_users_table.up.sql`.
- **The `go.sum` file is auto-generated.** If you add a Go dependency, run `go mod tidy` and commit the updated `go.mod` AND `go.sum`.

## What NOT to Do

- ❌ Do NOT use `gorilla/mux` — we use `chi`. If you're adding routes, follow the pattern in `api/main.go`.
- ❌ Do NOT add new npm dependencies without discussing it first. The frontend bundle size is a priority.
- ❌ Do NOT modify files in `api/db/migrations/` that have already been applied (anything older than 1 week). Create a new migration instead.
- ❌ Do NOT `console.log()` in production frontend code. Use the `logger` utility in `src/lib/logger.ts`.
- ❌ Do NOT hardcode secrets, API keys, or passwords anywhere. Use environment variables loaded from `.env.local` (locally) or the secrets manager (in production).
```

---

## Where to Put AGENTS.md

Always at the **root** of the repository:

```
my-project/
├── AGENTS.md          ← Here
├── README.md
├── ...
```

If you have a monorepo with very distinct sub-projects, you can also put an `AGENTS.md` inside each sub-project directory with sub-project-specific context. The agent will look for the one closest to the files it's working with.

---

## Keeping AGENTS.md Updated

`AGENTS.md` is only useful if it's accurate. Treat it like a first-class code file:
- Update it when you add a new major dependency
- Update it when a convention changes
- Update it when you discover a new gotcha
- Add it to your PR review checklist: *"Did this change require an update to AGENTS.md?"*

A stale `AGENTS.md` is almost worse than no `AGENTS.md` — it gives the agent confidently wrong information.
