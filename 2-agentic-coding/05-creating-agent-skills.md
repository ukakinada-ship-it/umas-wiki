# Creating Agent Skills: Worked Examples

A **Skill** is a reusable, documented procedure stored in your repository that tells the agent how to perform a complex, project-specific task. Skills let you encode your team's institutional knowledge into a format the agent can execute consistently.

Think of a Skill as a runbook written for an AI — far more detailed and precise than documentation written for humans.

---

## Where to Store Skills

Create a `docs/skills/` directory at the root of your repo:

```
my-project/
├── AGENTS.md
├── docs/
│   └── skills/
│       ├── add-api-route.md
│       ├── add-db-migration.md
│       └── refactor-module.md
```

---

## Invoking a Skill

When working with Antigravity, invoke a skill by referencing it directly in your prompt:

> *"I need to add a new endpoint for `GET /api/users/{id}/orders`. Please read `docs/skills/add-api-route.md` and follow those instructions."*

The agent will read the skill file, internalize the instructions, and execute the full workflow.

---

## Worked Example 1: Adding a REST API Route

**File:** `docs/skills/add-api-route.md`

```markdown
# Skill: Add a New REST API Route

## When to Use
Use this skill any time the user asks to add a new HTTP endpoint to the Go API.

## Prerequisites
- The resource name and HTTP method are known (e.g., "GET /api/products/{id}")
- Any new DB table required is already created via a migration

## Instructions

### Step 1: Create or update the handler file
Open `api/handlers/`. If a handler file for this resource already exists (e.g., `products_handler.go`),
add the new handler function to it. If this is a brand new resource, create a new file:
`api/handlers/{resource}_handler.go`.

Handler function naming convention: `{HTTPVerb}{Resource}Handler`
Example: `GetProductHandler`, `CreateProductHandler`, `ListProductsHandler`

Handler signature (always the same):
```go
func GetProductHandler(w http.ResponseWriter, r *http.Request) {
    // ...
}
```

### Step 2: Add the DB query (if this endpoint reads or writes data)
Open `api/db/queries/`. Create or update the file `{resource}_queries.go`.
Write the SQL as a raw string constant. Example:
```go
const getProductByIDQuery = `
    SELECT id, name, price, created_at
    FROM products
    WHERE id = $1
`
```

### Step 3: Register the route
Open `api/main.go`. Find the `registerRoutes` function. Add the new route following the existing pattern:
```go
r.Get("/api/products/{id}", handlers.GetProductHandler)
```
Routes are registered using the `chi` router. Use `.Get`, `.Post`, `.Put`, `.Delete`, `.Patch`.

### Step 4: Write tests
Create or update `api/handlers/{resource}_handler_test.go`.
Write at minimum:
- A test for the happy path (valid request, correct response)
- A test for the not-found case (if applicable)
- A test for a bad request (malformed ID, missing required fields)

### Step 5: Verify
Run: `bazel test //api/handlers:all`
All tests must pass before the task is complete.
```

---

## Worked Example 2: Adding a Database Migration

**File:** `docs/skills/add-db-migration.md`

```markdown
# Skill: Add a Database Migration

## When to Use
Use this skill when a task requires modifying the database schema:
adding a table, adding a column, changing a column type, or adding an index.

## Prerequisites
- You are running inside the dev Docker container
- PostgreSQL is running (`docker compose up -d db`)

## Instructions

### Step 1: Create the migration files
Run the following command (replace `description` with a short snake_case description):
```bash
migrate create -ext sql -dir api/db/migrations -seq add_description_here
```
This creates two files:
- `api/db/migrations/000X_add_description_here.up.sql`
- `api/db/migrations/000X_add_description_here.down.sql`

### Step 2: Write the UP migration
In the `.up.sql` file, write the SQL to apply the change:
```sql
-- 000X_add_orders_table.up.sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_cents INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_user_id ON orders(user_id);
```

### Step 3: Write the DOWN migration
In the `.down.sql` file, write the SQL to UNDO the change:
```sql
-- 000X_add_orders_table.down.sql
DROP TABLE IF EXISTS orders;
```
Always write the down migration. Even if we never run it in production,
it is used in tests to reset state.

### Step 4: Apply the migration
```bash
migrate -path api/db/migrations -database $DATABASE_URL up
```

### Step 5: Verify
```bash
# Connect to the DB and verify the schema change
psql $DATABASE_URL -c "\d orders"

# Run all DB-related tests
bazel test //api/db/...
```

### Step 6: Update the Go model
If this migration adds a new table, also create the corresponding Go struct in `api/models/`.
Follow the naming and tagging conventions in `api/models/user.go` as a reference.
```

---

## Worked Example 3: Refactoring a Module

**File:** `docs/skills/refactor-module.md`

```markdown
# Skill: Refactor a Module

## When to Use
When a module has grown too large, mixes too many concerns, or needs to be split up.

## Instructions

### Step 1: Read and understand before touching anything
Read the entire module to be refactored. List all the functions, their responsibilities,
and which other files import from this module.
Run: `grep -r "\"myproject/api/old-package\"" --include="*.go" .`
to find all callers.

### Step 2: Create the new package structure
Create new directories and `BUILD.bazel` files for the new packages.
Do NOT delete any existing code yet.

### Step 3: Move code incrementally, one function at a time
Move one function to its new home, update all callers, run `bazel build //...` to
confirm it compiles, and run `bazel test //...` to confirm tests still pass.
Repeat for each function. Never move multiple functions at once without verifying in between.

### Step 4: Delete the old code
Only after all functions are moved and all tests pass, delete the old module files.
Run `bazel build //...` and `bazel test //...` one final time.

### Step 5: Update ARCHITECTURE.md
If this refactor changes the high-level structure, update `ARCHITECTURE.md` to reflect it.
```

---

## Tips for Writing Your Own Skills

1. **Write for zero context.** Assume the agent has never seen the repo before.
2. **Include exact commands.** Don't say "run the tests." Say `bazel test //api/handlers:all`.
3. **Include the verification step.** Always end with how the agent proves it succeeded.
4. **Reference example files.** "Follow the pattern in `api/handlers/user_handler.go`" is gold.
5. **List what NOT to do.** Explicit prohibitions prevent the most common failure modes.
