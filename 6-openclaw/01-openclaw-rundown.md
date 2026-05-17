# OpenClaw: The Personal AI Assistant

**OpenClaw** is a production-grade, local-first personal AI assistant framework designed to run on your own devices and connect to the channels you already use (Slack, WhatsApp, Telegram, iMessage, etc.). It acts as your second brain, operating directly on your host machine or in isolated sandboxes to execute complex commands, interact with local APIs, manage databases, and even control your desktop or companion apps.

---

## 🦞 The Architecture: Local-First Control Plane

At its core, OpenClaw is split into a **Gateway (Control Plane)** and **Agents/Clients**:

```
                  ┌──────────────────────┐
                  │   Inbound Channels   │ (Telegram, WhatsApp, Slack, etc.)
                  └──────────┬───────────┘
                             │ (Secure pairing allowlist)
                             ▼
                  ┌──────────────────────┐
                  │  OpenClaw Gateway    │ (Local-first control plane)
                  └──────────┬───────────┘
                             │
            ┌────────────────┴────────────────┐
            ▼                                 ▼
┌──────────────────────┐           ┌──────────────────────┐
│  Workspace (Core)    │           │    Client Nodes      │
│  ~/.openclaw/        │           │  macOS / iOS /       │
│  - Prompt templates  │           │  Android Canvas UI   │
│  - 50+ Bundled Skills│           └──────────────────────┘
└──────────────────────┘
```

1. **Local-first Gateway**: Single control plane for sessions, channels, tools, and events. It exposes a WebSocket server that connects to companion apps and nodes.
2. **Secure Defaults**: Inbound messages from channels are strictly gated behind `dmPolicy="pairing"`. Senders must provide a pairing code to prevent unauthorized shell executions on your system.
3. **Sandbox Mode**: For public/group chat deployments, non-main sessions run inside secure sandbox environments (Docker, SSH, or OpenShell) to isolate processes, directories, and network access.

---

## 🚀 Setting Up OpenClaw

### Runtime Requirements
- **Node.js** (Node 24 recommended, Node 22.16+ minimum)
- **Package Manager**: `npm`, `pnpm`, or `bun`

### Recommended Global Installation
To install the latest release globally and setup the Gateway daemon (which keeps the service running under `systemd` or `launchd`):

```bash
npm install -g openclaw@latest
openclaw onboard --install-daemon
```

### Running from Source (Development)
If you want to modify OpenClaw or build extensions, run it locally via a workspace:

```bash
# Clone the repository
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# Install monorepo dependencies (pnpm is required for the source checkout)
pnpm install

# Initialize local developer workspace configuration
pnpm openclaw setup

# Build the Control UI
pnpm ui:build

# Start the dev loop with hot-reloading
pnpm gateway:watch
```

---

## 🧩 The Skills System: AI Blueprints

In OpenClaw, a **Skill** is a documented, reusable capability represented by a single markdown file with YAML frontmatter. Skills act as executable "runbooks" for the AI agent.

Every skill is placed under `skills/<skill-name>/SKILL.md` or dynamically loaded from `~/.openclaw/workspace/skills/<skill-name>/SKILL.md`.

### Anatomy of an OpenClaw Skill File

Here is how a Skill like `weather` is defined. The agent reads the frontmatter metadata to know how to install requirements, and then follows the commands:

```markdown
---
name: weather
description: "Current weather and forecasts with wttr.in via curl for locations, rain, temperature, travel planning."
homepage: https://wttr.in/:help
metadata:
  {
    "openclaw":
      {
        "emoji": "☔",
        "requires": { "bins": ["curl"] },
        "install":
          [
            {
              "id": "brew",
              "kind": "brew",
              "formula": "curl",
              "bins": ["curl"],
              "label": "Install curl (brew)",
            },
          ],
      },
  }
---

# Weather

Use for current weather, rain/temperature checks, forecasts, and travel planning. Need a city, region, airport code, or coordinates.

## Commands

```bash
curl "wttr.in/London?format=3"
curl "wttr.in/London"
```
```

### Highlight Skills Bundled with OpenClaw
OpenClaw ships with over **50+ built-in skills** out of the box to control your system:

| Skill | Category | Emoji | What it does |
|---|---|---|---|
| `coding-agent` | AI Delegation | 🧩 | Delegates complex coding work to Claude Code, Codex, or Pi as background workers with notifications. |
| `1password` | Security | 🔑 | Secure password/vault query capabilities via 1Password CLI. |
| `apple-notes` / `bear-notes` | Productivity | 📝 | Create, read, and search local notes on macOS. |
| `obsidian` | Knowledge Base | 📓 | Append or query your local Obsidian vaults. |
| `weather` | Utility | ☔ | Check current conditions and forecast details via wttr.in. |
| `openai-whisper` | Voice | 🎙️ | High-quality audio transcription for voice-wake interactions. |
| `trello` / `things-mac` | Task Management | 📋 | Task synchronization, inbox triage, and todo planning. |
| `slack` / `discord` | Automation | 💬 | Post notifications, execute channel actions, and monitor chats. |

---

## 🛠️ The Flagship Skill: Coding Agent (`skills/coding-agent`)

The `coding-agent` skill is a perfect showcase of advanced agentic orchestration. It tells the OpenClaw agent how to spawn background subprocesses using heavy coding agents (like Claude Code, OpenAI Codex, or Pi) in isolated checkouts, capture the notification routes, and send back PR status updates:

### Spawning a Worker Subprocess

The skill specifies the precise syntax to execute workers, mapping output to a temporary prompt descriptor file:

```bash
# 1. Create a prompt with task context + notification callback route
PROMPT=$(mktemp -t openclaw-worker-prompt.XXXXXX)
cat >"$PROMPT" <<'EOF'
Build the new API deactivation route inside api/handlers.
Notification route:
- channel: slack
- target: '#engineering-alerts'
EOF

# 2. Spawn the worker in the background (using Claude Code for bypass permissions mode)
claude --permission-mode bypassPermissions --print < "$PROMPT"
```

Once the worker completes, it executes a callback command to notify the gateway:
```bash
openclaw message send --channel slack --target '#engineering-alerts' --message 'Deactivation endpoint completed, PR opened.'
```

This model turns your personal assistant into a dispatch gateway, directing specialized AI coding subagents to perform parallel feature builds while you continue other tasks.
