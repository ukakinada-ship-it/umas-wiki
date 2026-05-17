# Version Control Basics

Welcome to the world of Version Control! Before diving into commands, it's crucial to understand what version control is and why we use it.

## What is Version Control?
Version Control Systems (VCS) are software tools that help software teams manage changes to source code over time. They keep track of every modification to the code in a special kind of database. If a mistake is made, developers can turn back the clock and compare earlier versions of the code to help fix the mistake while minimizing disruption to all team members.

## Why use Version Control?
1. **History:** You have a complete history of every file, who changed what, and when.
2. **Branching and Merging:** You can work on an isolated "branch" of the project, make your changes, and then "merge" them back into the main project without breaking things for others.
3. **Collaboration:** Multiple people can work on the same project simultaneously without overwriting each other's changes.
4. **Traceability:** You can tie changes back to bug reports or feature requests.

## What is Git?
Git is the most widely used modern version control system in the world today. It is a **Distributed Version Control System (DVCS)**.

### The "Distributed" Part
Unlike older centralized systems (like Subversion or CVS) where you need a network connection to a central server to commit changes, Git is distributed. This means that every developer's computer has a full, local copy of the entire project's history. You can commit changes locally, offline, and later synchronize those changes with a remote server (like GitHub).

## Git Concepts to Know
- **Repository (Repo):** A folder that Git is tracking. It contains your project files and the hidden `.git` folder with the version history.
- **Commit:** A snapshot of your repository at a specific point in time. Think of it as a "save point" in a video game.
- **Branch:** A parallel version of a repository. It's a way to work on new features or bug fixes independently of the main codebase (usually called `main` or `master`).
- **Merge:** Taking the changes from one branch and integrating them into another.
- **Remote:** A version of your repository hosted on the internet or another network (e.g., GitHub, GitLab).
- **Clone:** Copying a repository from a Remote to your local machine.

## Summary
Version control acts as a safety net and a collaboration engine. In the next section, we will see how to actually interact with Git using the command line (Terminal).
