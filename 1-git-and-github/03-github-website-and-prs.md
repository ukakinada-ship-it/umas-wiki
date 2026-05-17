# GitHub Website and Pull Requests

If Git is the engine that tracks your code history locally, GitHub is the cloud platform that hosts your repositories and enables collaboration at scale.

## What is GitHub?
GitHub is a hosting service for Git repositories. It provides a web-based interface and adds collaboration features on top of Git, such as issue tracking, code review tools, and CI/CD pipelines (GitHub Actions).

## The Core Concept: Pull Requests (PRs)
A Pull Request (PR) is the fundamental unit of collaboration on GitHub. It is a request to "pull" the changes from your branch into another branch (usually the `main` branch).

### Why use Pull Requests?
1. **Code Review:** Before code is merged into the main project, peers can review it, catch bugs, suggest improvements, and ensure it meets standards.
2. **Discussion:** It provides a dedicated space to discuss the specific changes being proposed.
3. **Testing:** Automated tests can run against the PR code to ensure it doesn't break existing functionality before it's merged.

## Anatomy of a Pull Request
When you open a PR on GitHub, you will see several key areas:
- **Title and Description:** Explains *what* the PR does and *why*. Good descriptions link to relevant issue trackers (e.g., "Fixes #123").
- **Commits Tab:** Shows the individual Git commits that make up the PR.
- **Files Changed (Diffs):** The most important tab for reviewers. It shows exactly what lines of code were added, modified, or deleted.
- **Checks:** Displays the status of automated tests or linters running against your code.

## The PR Workflow
1. **Push your branch:** After making commits locally, push your branch to GitHub (`git push -u origin my-feature`).
2. **Open the PR:** Navigate to your repository on GitHub. You'll usually see a prompt suggesting you open a PR for your recently pushed branch. Click "Compare & pull request".
3. **Fill out the details:** Provide a clear title and description.
4. **Request Reviewers:** Tag teammates to review your code.
5. **Address Feedback:** Reviewers might leave comments on specific lines of code. Make changes locally, commit, and push them to your branch. The PR will automatically update.
6. **Merge:** Once approved and all checks pass, click the "Merge pull request" button.
7. **Cleanup:** Delete your branch on GitHub and locally to keep things tidy.

## Navigating the GitHub Website
- **Issues:** Use this tab to track bugs, enhancements, or tasks. It's like a built-in to-do list for your repo.
- **Actions:** This is GitHub's CI/CD (Continuous Integration/Continuous Deployment) system. It can automatically run scripts when you push code (like running tests or deploying to a server).
- **Settings:** Manage repository access, setup branch protection rules (e.g., "require a review before merging"), and configure integrations.

Next, we'll dive deeper into how to actually read and understand code changes using Diffs.
