# The End-to-End Agentic Git Workflow

This page walks through a complete, realistic engineering task from feature request to merged pull request — using Antigravity and `gh` CLI to handle the entire workflow.

---

## The Scenario

You're a solo engineer building a Go REST API. Your product manager sends you a message:

> *"We need to be able to deactivate users without deleting them. Add an `is_active` flag and an admin endpoint to toggle it. Inactive users should get a 403 if they try to log in."*

Let's walk through this together.

---

## Step 1: Understand Before You Prompt

Before opening the agent, spend 2 minutes orienting yourself. Look at:
- What does the `users` table look like? (`api/db/migrations/`)
- How does the login endpoint work? (`api/handlers/auth_handler.go`)
- How are admin-only routes protected? (`api/middleware/`)

Even a quick skim helps you write a much better prompt — you can reference specific files, which saves the agent time and reduces mistakes.

---

## Step 2: Write Your Prompt

Here's the prompt you send to Antigravity:

> "Implement user deactivation. Here's everything you need to know:
>
> **Database change:** Add an `is_active BOOLEAN NOT NULL DEFAULT TRUE` column to the `users` table. Create the migration using `docs/skills/add-db-migration.md`.
>
> **Login change:** In `api/handlers/auth_handler.go`, in `LoginHandler`, after the user is fetched from the DB and the password is verified, check if `user.IsActive` is `false`. If so, return HTTP 403 with body `{"error": "account deactivated"}`.
>
> **New admin endpoint:** Add `PATCH /api/admin/users/{id}/deactivate` and `PATCH /api/admin/users/{id}/activate`. These should set `is_active` to `false` and `true` respectively. Admin routes are protected by the `AdminOnly` middleware — see how it's used in `api/main.go`. Follow the `docs/skills/add-api-route.md` skill.
>
> **Tests:** 
> - Add a test to `api/handlers/auth_handler_test.go` that confirms a deactivated user gets a 403 on login
> - Add tests to `api/handlers/admin_handler_test.go` for the activate/deactivate endpoints
>
> **Verify:** Run `bazel test //api/...` before reporting done. All tests must pass."

This is a well-crafted prompt: it references specific files, references existing skills, specifies exact test cases, and includes a verification command.

---

## Step 3: Review the Plan

Because this is a multi-file change, Antigravity enters Planning Mode and presents an implementation plan:

```markdown
## Proposed Changes

### Database
#### [NEW] api/db/migrations/0005_add_is_active_to_users.up.sql
#### [NEW] api/db/migrations/0005_add_is_active_to_users.down.sql

### Go API
#### [MODIFY] api/models/user.go
Add `IsActive bool` field to the `User` struct.

#### [MODIFY] api/db/queries/user_queries.go
Update `getUserByIDQuery` to select the `is_active` column.

#### [MODIFY] api/handlers/auth_handler.go
Add is_active check in LoginHandler after password verification.

#### [MODIFY] api/handlers/admin_handler.go
Add ActivateUserHandler and DeactivateUserHandler functions.

#### [MODIFY] api/main.go
Register the two new admin routes under the AdminOnly middleware.

## Open Questions
> Should the 403 response for a deactivated user say "account deactivated" 
> (which reveals the account exists) or use the same generic "invalid credentials" 
> message as a wrong password (for security)?
```

The agent is asking a **good security question** here. You answer:

> "Use the generic 'invalid credentials' message for security."

The agent notes your decision and proceeds.

---

## Step 4: Review the Diff

The agent executes and reports: *"All tests passing. Here's what I changed."*

Now you review the diff carefully. On GitHub or in your editor, you check:

1. **Migration:** Is the SQL correct? Does it have a proper down migration?
2. **Model:** Is the new field nullable or non-nullable? (Should be non-nullable with a default.)
3. **Auth handler:** Did it actually use the generic message like you specified?
4. **Admin handler:** Are both activate AND deactivate implemented?
5. **Tests:** Are there tests for the deactivated login 403? Are they actually asserting the right status code?

You spot one issue: the deactivate endpoint test is asserting a 200 status, but it should assert that the user's `is_active` field in the DB is now `false`. You send feedback:

> "The test `TestDeactivateUser` only checks for a 200 status. Also assert that after the call, fetching the user from the DB returns `is_active = false`."

The agent updates the test. Now everything looks good.

---

## Step 5: Create the Pull Request

You're happy with the changes. Time to ship:

```bash
# The agent already committed the changes on a branch.
# If it didn't, commit now:
git add .
git commit -m "feat: add user deactivation with admin endpoints"

# Push the branch
git push -u origin feat/user-deactivation

# Open a PR using gh CLI
gh pr create \
  --title "feat: Add user deactivation" \
  --body "Adds is_active flag to users table. Inactive users get 401 on login. Admin can activate/deactivate via PATCH endpoints. Closes #42." \
  --reviewer your-teammate
```

Or even simpler — ask Antigravity to do this step too:

> "Create a PR for the current changes. Title: 'feat: Add user deactivation'. Body: 'Adds is_active flag, login check, and admin endpoints. Closes #42.' Request review from @your-teammate."

---

## Step 6: Merge

Your teammate reviews, approves, and you merge:

```bash
gh pr merge --squash --delete-branch
```

**Total time:** ~25 minutes, mostly spent on review. The implementation itself took the agent ~3 minutes.

---

## Key Takeaways

| Phase | Your Job | Agent's Job |
|-------|----------|-------------|
| Planning | Orient yourself, write a precise prompt | Research the codebase, create implementation plan |
| Execution | Review & approve the plan | Write all the code, run tests |
| Review | Carefully read the diff, catch mistakes | Self-correct when given feedback |
| Ship | Decide it's ready | Create the PR (optionally) |

The ratio you should target: **80% of your time on thinking and reviewing**, 20% on prompting and guiding. If you're spending more than 20% writing code yourself, you're underutilizing the agent.
