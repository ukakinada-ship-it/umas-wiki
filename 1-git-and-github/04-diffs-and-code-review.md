# Diffs and Code Review

When you review a Pull Request or run `git diff` in your terminal, you are looking at a "diff". Understanding how to read diffs is essential for tracking down bugs, reviewing a teammate's code, or just verifying your own work before committing.

## What is a Diff?
A diff (short for difference) shows exactly what changed between two states of a file. It highlights additions, deletions, and modifications.

## Reading a Diff
Let's look at a typical diff output (often called a "unified diff"):

```diff
--- a/calculator.py
+++ b/calculator.py
@@ -10,6 +10,10 @@
 def add(a, b):
     return a + b
 
-def subtract(a, b):
-    return a - b
+def subtract(num1, num2):
+    return num1 - num2
+
+def multiply(a, b):
+    return a * b
```

### Breaking it down:
1. **The Header (`---` and `+++`):**
   - `--- a/calculator.py`: Represents the *original* file.
   - `+++ b/calculator.py`: Represents the *new* file (with your changes).

2. **The Hunk Header (`@@ -10,6 +10,10 @@`):**
   - This tells you *where* the change happened.
   - `-10,6`: In the original file, we are looking at a chunk starting at line 10, spanning 6 lines.
   - `+10,10`: In the new file, this chunk starts at line 10 and now spans 10 lines (because we added lines).

3. **The Content:**
   - **Blank prefix ( ):** Lines that are unchanged. They are provided for context.
   - **Minus prefix (`-`):** Lines that were **deleted** (or modified from the original). Usually highlighted in red.
   - **Plus prefix (`+`):** Lines that were **added** (or modified to the new state). Usually highlighted in green.

*In the example above, we renamed the arguments in the `subtract` function and added a completely new `multiply` function.*

## Diffs in the Terminal
- `git diff`: Shows changes in your Working Directory that haven't been staged yet.
- `git diff --staged` (or `--cached`): Shows changes that have been staged (what will go into your next commit).
- `git diff branch_A branch_B`: Shows the difference between two branches.

## Effective Code Review
When reading diffs in a Pull Request on GitHub, follow these best practices for effective code review:

1. **Understand the Goal:** Read the PR description first. What problem is this code trying to solve?
2. **Look at the Big Picture:** Don't get bogged down in typos first. Does the overall architecture and approach make sense?
3. **Check for Edge Cases:** Did the author handle null values, empty strings, or network failures?
4. **Be Constructive, not Destructive:** When leaving comments, critique the code, not the person. Suggest alternatives rather than just saying "this is wrong".
   - *Bad:* "Why did you do it this way? This is inefficient."
   - *Good:* "This loop works, but we might hit performance issues for large arrays. Have you considered using a dictionary lookup here instead?"
5. **Ask Questions:** If you don't understand a piece of code, ask! "Can you explain how this regex works?"
6. **Approve Explicitly:** Once all concerns are addressed, officially "Approve" the PR to signal it's ready to merge.

Mastering diffs and code reviews makes you a significantly better engineer and teammate. Now that we have a solid foundation in collaboration tools, let's explore how AI can supercharge this process in the Agentic Coding section.
