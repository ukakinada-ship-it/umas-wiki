# Reviewing Agent-Generated Code

Writing code with an agent is only half the job. Reviewing it effectively is the other half — and it's where your engineering judgment is irreplaceable.

An AI agent can write a lot of correct code very quickly. It can also confidently write subtly wrong code very quickly. The only thing standing between that code and production is your review.

---

## The Golden Rule: Never Blindly Accept

An agent saying "all tests pass" is not sufficient proof that code is correct. Tests can pass and code can still be:
- Logically wrong (the test doesn't cover the actual bug)
- Insecure (SQL injection, missing auth checks)
- Architecturally wrong (violates your patterns in a way that will cause problems later)
- Silently broken for edge cases the tests don't cover

**Treat every agent-generated PR as if it came from a very fast, very confident junior developer.** Review it with the same care you would apply to that code.

---

## A Systematic Review Checklist

### ✅ Correctness
- [ ] Does it do what was asked? Read the diff against the original requirements.
- [ ] Are error cases handled? (What if the DB is down? What if the input is null?)
- [ ] Are there off-by-one errors or incorrect boolean logic?
- [ ] Is the response body/status code correct for every code path?

### ✅ Security
- [ ] Are user inputs validated and sanitized?
- [ ] Are DB queries parameterized? (Never `"SELECT ... WHERE id = " + userInput`)
- [ ] Is authentication/authorization checked on the new endpoint?
- [ ] Is any sensitive data (passwords, tokens) logged or returned?

### ✅ Tests
- [ ] Do the tests actually test what they claim to test?
- [ ] Do the tests cover failure cases, not just the happy path?
- [ ] Are tests checking the right thing? (Status code AND response body, not just status code)
- [ ] Did the agent write tests that are trivially true? (E.g., asserting that `1 == 1`)

### ✅ Consistency
- [ ] Does it follow the naming conventions of the rest of the codebase?
- [ ] Does it follow the error handling patterns?
- [ ] Does it use the approved libraries, not a random one the agent chose?
- [ ] Does it fit the architectural patterns described in `ARCHITECTURE.md`?

### ✅ Clean-up
- [ ] Are there any debug `print` / `console.log` / `fmt.Println` statements left in?
- [ ] Are there any TODO comments the agent left that should have been implemented?
- [ ] Are there any unused imports, variables, or functions?

---

## Common Failure Modes of Agent Code

### 1. The Hallucinated Library
**Pattern:** The agent imports a library that doesn't exist in your `go.mod` / `package.json` / `requirements.txt`, or that exists but has a completely different API than the agent used.

**How to catch it:** `bazel build //...` will fail. But also check imports by eye — if you see a library you don't recognize, verify it's actually installed and the API the agent used is correct.

### 2. The Untested Edge Case
**Pattern:** The agent writes a function that works for the happy path but silently fails for empty arrays, zero values, nil pointers, or concurrent access.

**Example:**
```go
// Agent wrote this - works if user is found, panics if not
user := getUserFromDB(id)
if user.IsActive {
    ...
}
// Should be:
user, err := getUserFromDB(id)
if err != nil || user == nil {
    return nil, ErrUserNotFound
}
```

**How to catch it:** Read the function with adversarial eyes. Ask: *"What happens if X is nil? What if the array is empty? What if two goroutines call this simultaneously?"*

### 3. The Auth Check Omission
**Pattern:** The agent adds a new endpoint but forgets to put it behind the authentication middleware.

**How to catch it:** Look at route registration in `main.go` or router file. Every new route should be obviously inside the right middleware group.

### 4. The Wrong Convention
**Pattern:** The agent logs using `fmt.Println` instead of `slog`, or returns errors without wrapping them, because it didn't read `AGENTS.md` carefully.

**How to catch it:** This is why having `AGENTS.md` and running linters matters. After reviewing, run `bazel test //tools:lint` or equivalent.

### 5. The Overfit Test
**Pattern:** The agent writes a test that tests its *own implementation* rather than the *requirement*. If the implementation is wrong, the test is also wrong.

**Example:** You ask for an endpoint that returns the *youngest* user. The agent mistakenly implements it as *oldest* user, then writes a test that verifies the *oldest* user is returned. The test passes. But it's wrong.

**How to catch it:** Read tests independently of the implementation. Ask: *"If I reimplemented this correctly from scratch, would this test still pass?"*

---

## How to Give Effective Correction Feedback

When you spot a problem, be specific about what's wrong AND what the correct behavior should be.

**❌ Vague:**
> "The auth handling is wrong."

**✅ Specific:**
> "The `CreateOrderHandler` is missing an auth check. All `/api/orders/*` routes should be behind the `RequireAuth` middleware. Look at how `CreateProductHandler` is registered in `main.go` — the order route needs to be inside the same middleware group."

---

## When to Reject and Re-Prompt vs. Manual Fix

| Situation | Action |
|-----------|--------|
| Small typo or naming issue | Manual fix — faster than re-prompting |
| Logic error in one function | Give specific feedback, let agent fix |
| Agent used wrong architectural pattern | Reject and re-prompt with clearer constraints |
| Agent fundamentally misunderstood the requirement | Reject and re-prompt with clearer requirements |
| 5+ issues across many files | Ask agent to revert and start over with a revised prompt |
| Security vulnerability | Always manual review + fix, never trust agent to self-correct security issues without your verification |

---

## Building Review Muscle Memory

The more you review agent code, the better you get at spotting its failure modes. Keep a mental (or literal) list of mistakes you've caught before — they tend to repeat. Add the most common ones to `AGENTS.md` under "What NOT to do" so the agent stops making them.
