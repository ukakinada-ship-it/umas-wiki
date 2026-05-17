# The GitHub CLI (`gh`)

The GitHub website is great, but switching between your terminal and browser constantly breaks your flow. The **GitHub CLI** (`gh`) brings the full power of GitHub directly into your terminal, so you can manage repositories, pull requests, issues, and more without ever leaving the command line.

## Installing `gh`
On Ubuntu/Debian:
```bash
sudo apt-get install gh
```
On macOS:
```bash
brew install gh
```

## Authenticating with GitHub
Before you can use `gh`, you need to log in once:
```bash
gh auth login
```
It will walk you through an interactive prompt asking you to choose:
1. **GitHub.com** (or Enterprise)
2. **SSH** as the preferred protocol (recommended — this uses your SSH key we set up earlier!)
3. Open a browser to complete the authentication

Once done, your terminal is fully authenticated with your GitHub account.

## Creating a Repository
Instead of going to github.com to click "New repository," just do this:
```bash
# Creates a new PUBLIC repo called "my-project" on GitHub and sets it as the remote
gh repo create my-project --public --source=. --push
```
Key flags:
- `--public` / `--private`: Visibility of the repo.
- `--source=.`: Use the current directory as the local source.
- `--push`: Immediately push the current branch to the newly created remote.

## Working with Pull Requests
This is where `gh` really shines. You can do the entire PR lifecycle from the terminal.

```bash
# Create a PR from your current branch
gh pr create --title "Add login feature" --body "Implements the user login page"

# List all open PRs in the repo
gh pr list

# View the details of a specific PR
gh pr view 42

# Check out a PR locally to test it
gh pr checkout 42

# Merge a PR
gh pr merge 42 --squash
```

## Working with Issues
```bash
# Create a new issue
gh issue create --title "Bug: Login fails on mobile" --body "Steps to reproduce..."

# List all open issues
gh issue list

# Close an issue
gh issue close 42
```

## Cloning a Repository
Instead of hunting for the SSH URL on GitHub, just:
```bash
gh repo clone username/repository-name
```

## Browsing GitHub from the Terminal
```bash
# Open the current repo in your browser
gh browse

# Open a specific PR in your browser
gh browse --pr 42
```

## Checking the Status of CI/CD Checks
```bash
# See the status of checks running on your current branch
gh pr checks
```

## Why `gh` Matters for Agentic Coding
The `gh` CLI is a critical tool for AI agents. Since agents primarily interact with your computer through a terminal, `gh` allows an agent to perform the *entire* GitHub workflow autonomously:
- Create repos
- Open PRs
- Read and close issues
- Merge branches

Without `gh`, an agent would have to ask you to switch to the browser constantly. With it, the agent can work end-to-end without interrupting you.
