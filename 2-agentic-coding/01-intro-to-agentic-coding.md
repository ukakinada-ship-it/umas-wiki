# Introduction to Agentic Coding and Antigravity

## What Is Agentic Coding?

Traditional AI coding tools are "super-autocomplete." You type, they suggest the next few tokens. You are still the one reading documentation, running commands, writing files, searching the codebase, and deciding what to do next.

**Agentic coding** changes this entirely. An Agent is an AI system that can:
1. Receive a high-level task ("Add a user authentication system using JWT tokens")
2. Plan how to accomplish it
3. Use **tools** autonomously to execute that plan — reading files, writing files, running terminal commands, searching the web, creating GitHub PRs
4. Verify its own work (run unit tests, check for compile errors)
5. Self-correct when it encounters failures

You are no longer the code writer. You are the **engineering manager**, and the agent is your senior developer.

---

## Antigravity's Tool Belt

When Antigravity works on a task, it has access to a set of tools it can invoke autonomously. Understanding what these tools are helps you understand what the agent is capable of:

| Tool | What it does |
|------|-------------|
| `view_file` | Read any file in the codebase |
| `write_to_file` | Create new files |
| `replace_file_content` / `multi_replace_file_content` | Edit specific lines in existing files |
| `run_command` | Execute any shell command (build, test, install, git, etc.) |
| `grep_search` | Search for patterns across the entire codebase |
| `list_dir` | Explore the directory structure |
| `search_web` | Search the internet for documentation or answers |
| `read_url_content` | Read the contents of a URL |
| `browser_subagent` | Open a browser and interact with web pages |
| `generate_image` | Generate images |

This is a powerful toolkit. When you ask Antigravity to "add a new API endpoint," it will:
- Search the codebase for where existing routes are defined
- Read the relevant files to understand the pattern
- Write the new code
- Run your test suite to confirm nothing broke

---

## Planning Mode: Your Safety Net

For complex tasks, Antigravity enters **Planning Mode**. Instead of immediately making changes, it:

1. **Researches** the codebase thoroughly (reading files, searching for patterns)
2. **Creates an `implementation_plan.md`** — a detailed doc outlining every file it plans to touch, what it will change, and why
3. **Pauses and requests your review**
4. **Waits for your approval** before touching a single line of code

### Example Planning Mode in Action

Say you ask: *"Refactor the entire authentication module to use JWTs instead of session cookies."*

Antigravity will respond with a plan like:

```markdown
## Proposed Changes

### Auth Layer
#### [MODIFY] src/auth/session.go
Replace cookie-based session creation with JWT signing using the `golang-jwt/jwt` library.

#### [NEW] src/auth/jwt.go
New file containing JWT generation, validation, and refresh token logic.

#### [MODIFY] src/middleware/auth_middleware.go
Update the middleware to validate JWT from Authorization header instead of reading session store.

#### [DELETE] src/auth/session_store.go
This file becomes unnecessary once JWTs are in use.

## Open Questions
> Should the JWT secret be loaded from an environment variable or a secrets manager?
```

You review this plan, answer the open questions, and then approve. Only then does the agent start writing code. This prevents it from going down the wrong path for 20 minutes before you realize it misunderstood the requirements.

---

## Shifting Your Mindset

The biggest mistake new agentic coders make is treating the agent like a traditional chatbot — asking one tiny question at a time and typing the code themselves. Here's how to think differently:

### ❌ Old Mindset (Copilot style)
> "Write a function that parses a JSON file."

You then copy-paste the function into your code, manually add the import, hook it up to the caller, run it, fix the bugs, etc.

### ✅ Agentic Mindset
> "I need to load configuration from a `config.json` file at startup. The config should have `database_url`, `port`, and `log_level` fields. Add a `Config` struct, load it in `main.go` using a `LoadConfig()` function, and make sure it fails loudly (panics with a clear error message) if the file is missing or malformed. Run the existing tests to make sure nothing broke."

The agent will:
- Find `main.go` and understand the startup sequence
- Create the `Config` struct and `LoadConfig()` function
- Wire it into `main.go`
- Run `go test ./...`
- Fix any compilation errors
- Report back with what it did

This is the power of agentic coding. **One well-crafted prompt can replace 30-60 minutes of your own work.**

---

## The Learning Curve

Agentic coding has a different learning curve than traditional coding:
- The first few days feel slow because you're learning *how to communicate* with the agent effectively
- By week 2, you'll be shipping 2-3x faster than before
- The highest leverage skill is **writing clear requirements** — the same skill that makes you a good engineer in a team

The next pages in this section will teach you exactly how to do that.
