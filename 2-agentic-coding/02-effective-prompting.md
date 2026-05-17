# Effective Prompting for Agentic Coding

The quality of the agent's output is directly proportional to the quality of your prompt. A vague prompt produces vague code. A precise, context-rich prompt produces production-quality code. This page teaches you how to write the latter.

---

## The Anatomy of a Great Prompt

A great prompt has four components:

1. **Context** — What is the current state of the world?
2. **Task** — What exactly do you need done?
3. **Constraints** — What rules must the solution follow?
4. **Verification** — How will the agent know it succeeded?

---

## Before & After: Prompt Comparisons

### Example 1: Adding a database model

**❌ Bad prompt:**
> "Add a User model to the database"

Problems:
- Which database? (PostgreSQL, SQLite, Mongo?)
- Which ORM? (SQLAlchemy, Prisma, GORM?)
- What fields does User have?
- Where do migrations live?
- Should it run the migration?

**✅ Good prompt:**
> "Add a `User` model to our PostgreSQL database using SQLAlchemy (see `src/models/` for existing model examples).
> The User should have: `id` (UUID, primary key), `email` (string, unique, not null), `hashed_password` (string, not null), `created_at` (datetime, default now), `is_active` (boolean, default True).
> Create the Alembic migration file by running `alembic revision --autogenerate -m 'add_user_model'`.
> Run `alembic upgrade head` to apply it.
> Then run `pytest tests/models/` to make sure the existing model tests still pass."

---

### Example 2: Fixing a bug

**❌ Bad prompt:**
> "The login is broken, fix it"

**✅ Good prompt:**
> "The login endpoint at `POST /api/auth/login` is returning a 500 error when the user's email doesn't exist in the database. The error occurs in `src/api/auth_handler.go` in the `LoginHandler` function. Currently it tries to call `.HashedPassword` on a nil user object before checking if the user was found. Fix the nil check so it returns a proper `401 Unauthorized` response with the body `{"error": "invalid credentials"}` when the email is not found — do not leak whether the email exists or not (always return the same message for bad email OR bad password)."

---

### Example 3: Building a feature from scratch

**❌ Bad prompt:**
> "Add file upload support"

**✅ Good prompt:**
> "Add an image upload endpoint to the API.
>
> Requirements:
> - `POST /api/uploads/image` — accepts `multipart/form-data` with a field named `file`
> - Only accept JPEG and PNG files, reject others with a `400` and `{"error": "unsupported file type"}`
> - Max file size: 5MB. Reject larger files with `413` and `{"error": "file too large"}`
> - Save the file to the `./uploads/` directory with a UUID filename (preserve the extension)
> - Return `{"url": "/uploads/<uuid>.jpg"}` on success
>
> Look at how `POST /api/posts/create` handles request parsing in `src/handlers/posts.go` and follow the same pattern.
>
> Add at least 3 tests to `tests/handlers/upload_test.go`: one for a valid JPEG, one for an invalid file type, one for an oversized file.
> Run `go test ./tests/handlers/` before finishing."

---

## Providing Context Efficiently

### Reference Existing Code
Instead of explaining your architecture from scratch every time, point the agent at existing examples:
> "Follow the same pattern as `src/handlers/products.go` when creating the new handler."

The agent will read that file and understand your conventions automatically.

### Reference Your `AGENTS.md`
If your repo has an `AGENTS.md` file (covered in the next page), tell the agent:
> "Before starting, read `AGENTS.md` for context on our conventions."

### Paste Error Messages Directly
When debugging, paste the *full* error message and stack trace, not a paraphrase of it:
> "The build is failing with this error: [paste full error]"

---

## Scoping Tasks Correctly

### Too Small (Chatbot Mode)
> "Write a regex for validating email addresses."

You're just using the agent as a search engine. This is fine occasionally, but it doesn't leverage the agent's ability to execute.

### Too Large (Hallucination Zone)
> "Build me a full SaaS application with user authentication, billing, a dashboard, and an admin panel."

The agent will try, produce a massive amount of code, and most of it will be wrong or inconsistent. You won't be able to review it effectively.

### Just Right (The Sweet Spot)
A task that:
- Can be completed in a single logical unit
- Produces a reviewable diff of under ~500 lines
- Has a clear pass/fail criterion (tests pass, endpoint returns correct response)
- Doesn't require decisions you haven't already made

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad | Fix |
|---|---|---|
| "Do your best" | Gives the agent no quality target | Specify exact acceptance criteria |
| "Make it better" | Completely subjective | Say what dimension to improve: speed, readability, test coverage |
| Asking for 10 things in one prompt | The agent loses track of constraints | Break into sequential prompts |
| Not specifying which tests to run | Agent may declare success without verifying | Always end with `run X tests` |
| "Use any library you want" | Agent picks randomly, may conflict with your stack | Name the specific library |

---

## The Iteration Loop

Even with a great prompt, expect to iterate. The typical pattern is:

1. Send a well-crafted prompt
2. Agent executes and reports what it did
3. You review the diff
4. You either: **approve**, **request a specific fix**, or **ask it to revert and re-approach**

The key is to give precise correction feedback, not vague feedback:

**❌ Vague:** "The tests are failing, fix it."

**✅ Precise:** "The test `test_login_with_invalid_email` is failing because the handler is returning `404` but the test expects `401`. Update the handler to always return `401` for failed logins regardless of whether the email exists."
