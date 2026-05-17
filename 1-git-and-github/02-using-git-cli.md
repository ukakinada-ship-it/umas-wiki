# Using the Git CLI

While many graphical tools exist for Git, understanding the Command Line Interface (CLI) is a superpower. It's universally available, fast, and gives you complete control.

## The Three States of Git
Before typing commands, you must understand the three main states that your files can reside in:
1. **Modified (Working Directory):** You have changed the file but have not committed it to your database yet.
2. **Staged (Staging Area / Index):** You have marked a modified file to go into your next commit snapshot.
3. **Committed (Git Directory / History):** The data is safely stored in your local database.

## Essential Commands

### 1. `git init`
Initializes a new Git repository in the current directory.
```bash
# Navigate to your project folder
cd my-project
# Tell Git to start tracking it
git init
```

### 2. `git clone`
Downloads an existing repository from a remote server (like GitHub) to your computer.
```bash
git clone git@github.com:username/repository-name.git
```

### 3. `git status`
Your best friend. It tells you the state of your working directory and staging area. *Run this frequently.*
```bash
git status
```

### 4. `git add`
Moves changes from the Working Directory to the Staging Area.
```bash
# Stage a specific file
git add index.html

# Stage all changed files in the current directory
git add .
```

### 5. `git commit`
Takes a snapshot of your Staged files and saves them to the Git history. Always include a descriptive message!
```bash
git commit -m "Add login button to the homepage"
```

### 6. `git log`
Shows the history of commits for the repository.
```bash
git log
# For a more compact view:
git log --oneline
```

### 7. Branching Basics
Branches allow you to diverge from the main line of development.
```bash
# List all branches (current branch has a *)
git branch

# Create a new branch
git branch new-feature

# Switch to a branch
git checkout new-feature
# OR (newer command)
git switch new-feature

# Shortcut: Create and switch in one step
git checkout -b new-feature
```

### 8. Pushing and Pulling
Communicating with Remotes (GitHub).
```bash
# Upload your local commits to the remote repository
git push origin main

# If you just created a new branch locally and want to push it:
git push -u origin new-feature

# Download new commits from the remote and merge them into your current branch
git pull origin main
```

## Typical Workflow
1. Pull the latest code: `git pull`
2. Create a new branch: `git checkout -b my-new-feature`
3. Make changes to your files.
4. Stage the changes: `git add .`
5. Commit the changes: `git commit -m "Implement feature X"`
6. Push your branch to GitHub: `git push -u origin my-new-feature`
7. (On GitHub): Open a Pull Request.

In the next section, we'll look at the GitHub website and how Pull Requests fit into the picture.
