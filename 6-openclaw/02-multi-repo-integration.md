# Multi-Repo Integration with OpenClaw

When developing multiple, separate repositories (polyrepo style) rather than a single monorepo, you want your personal AI assistant to retain its skills, configurations, and shortcuts **no matter what repository or directory you are currently working in**.

OpenClaw supports this decoupling through a layered hierarchy: **Global Workspace context** for cross-project intelligence, and **Repository-specific overrides** for project boundaries.

---

## 🗺️ The Hierarchy of AI Context

OpenClaw merges context from three distinct layers before executing a session. This allows your custom skills and workflows to be available globally, while ensuring project-specific boundaries are strictly respected:

```
┌────────────────────────────────────────────────────────┐
│ 1. Global OpenClaw Profile (~/.openclaw/openclaw.json) │
│    - Global tools, API credentials, active channels.   │
└───────────────────────────┬────────────────────────────┘
                            │ (Merges with)
                            ▼
┌────────────────────────────────────────────────────────┐
│ 2. Global Workspace (~/.openclaw/workspace/)          │
│    - Global skills (~/workspace/skills/)               │
│    - Global directives (AGENTS.md, SOUL.md)            │
└───────────────────────────┬────────────────────────────┘
                            │ (Overridden by)
                            ▼
┌────────────────────────────────────────────────────────┐
│ 3. Repository Context (/home/uma/repos/project-a/)     │
│    - Local AGENTS.md (local styles, stack details)    │
│    - Isolated checkouts for background coding runs.   │
└────────────────────────────────────────────────────────┘
```

---

## 🛠️ Step 1: Centralizing Your Custom Skills Globally

To make your custom-written skills (like automated Docker builders, custom database triages, or Bazel test runners) available **everywhere**, place them in the global OpenClaw workspace directory instead of inside individual project repositories.

1. Create a dedicated skills folder in your global workspace:
   ```bash
   mkdir -p ~/.openclaw/workspace/skills
   ```
2. Save your custom skill here, for example: `~/.openclaw/workspace/skills/bazel-cleaner/SKILL.md`.
3. OpenClaw will automatically load this skill and make it available as a terminal-tool capability **no matter what directory you are currently in** when triggering your assistant.

---

## 🔌 Step 2: Sharing Skills via an External Skills Repository

If you want to maintain all your custom agent skills under version control without cluttering your core projects, you can store them in a single, dedicated repository (e.g., `uma-skills`) and mount it globally:

1. Clone your custom skills repository to a central location:
   ```bash
   git clone git@github.com:uma/uma-skills.git ~/repos/uma-skills
   ```
2. Open your global OpenClaw configuration file (`~/.openclaw/openclaw.json`).
3. Add your custom skills directory to the `plugins.localPaths` configuration block:
   ```json
   {
     "plugins": {
       "localPaths": [
         "/home/uma/repos/uma-skills"
       ]
     }
   }
   ```
4. Restart your OpenClaw gateway. Your custom skills are now registered globally and accessible across every project workspace.

---

## 📁 Step 3: Structuring Project-Specific Directives

While skills should live globally, specific instructions (like which Python version a project uses, unique build systems, or database schemas) must live inside the respective project repositories.

Place an `AGENTS.md` file in the root of **each** project repository:

### `/home/uma/repos/project-a/AGENTS.md`
```markdown
# Project A: Bazel C++ Service

## Tech Stack
- Build System: Bazel
- Language: C++17
- Target Binary: //src/main:web_server

## Rules for Agents
- Never build using raw g++ or clang; always run 'bazel build //...'
- If a build fails, inspect logs using 'bazel query' before attempting code edits.
```

### `/home/uma/repos/project-b/AGENTS.md`
```markdown
# Project B: Python FastAPI API

## Tech Stack
- Language: Python 3.11
- Framework: FastAPI
- Database: PostgreSQL

## Rules for Agents
- Run migrations using 'alembic upgrade head' before starting local testing.
- Write unit tests using pytest inside tests/ directory.
```

When you trigger a background `coding-agent` run from your chat app, specify the repository's path in the `workdir` block:
```bash
openclaw run --workdir /home/uma/repos/project-a --command "Build the new endpoint"
```
OpenClaw will switch to `/home/uma/repos/project-a`, locate the local `AGENTS.md` file, merge it with the global `~/.openclaw/workspace/AGENTS.md` system guidelines, and execute the task with absolute project context!

---

## 🚀 Step 4: Setting up Global Git Triggers

To make integration truly seamless, you can add simple alias triggers or global Git hooks so you can easily dispatch background work to OpenClaw from any terminal window.

Add the following helper aliases to your shell configuration (`~/.bashrc` or `~/.zshrc`):

```bash
# Dispatch a background coding task to OpenClaw for the current directory
alias clawit='openclaw run --workdir "$(pwd)" --background'

# Check the status of ongoing background processes
alias clawstatus='openclaw process list'

# Tail logs for the active session
clawlogs() {
  openclaw process log --session "$1"
}
```

Now, no matter what repository you have open in your terminal, you can easily dispatch background tasks:
```bash
# Navigate to any repository
cd ~/repos/my-web-app

# Kick off a background agent to write unit tests for a file
clawit --command "Add unit tests for handlers/auth.go"
```
The Gateway will seamlessly intercept the directory context, apply the local `AGENTS.md` rules, load your globally declared custom skills, perform the work in the background, and notify your Slack/Telegram channel upon completion.
