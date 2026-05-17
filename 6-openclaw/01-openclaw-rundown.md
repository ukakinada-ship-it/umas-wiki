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

## 🛡️ System & Developer Grounded Skills

OpenClaw is highly unique because it contains deep, system-level capabilities that go far beyond simple social-app parsing or calendar checks. These represent robust tools for developers, systems engineers, and power users.

### 1. OS-level UI Automation (`skills/peekaboo`)
Uses `peekaboo` (a specialized macOS Screen/Accessibility automation driver) to capture, inspect, and automate the macOS desktop environment. It allows the agent to visually parse the screen, target specific window bounds, and perform human-like input:
```bash
# Check Screen Recording & Accessibility permissions
peekaboo permissions

# Get a detailed visual annotated map of elements on screen
peekaboo see --annotate --path /tmp/screenshot.png

# Click an accessibility target by ID
peekaboo click --on B1

# Type text with human WPM pacing and trailing return
peekaboo type "Hello World" --wpm 110 --return
```

### 2. Node.js CDP Debugger (`skills/node-inspect-debugger`)
Allows the agent to attach to Node.js / TypeScript processes, inject Chrome DevTools Protocol (CDP) commands, step through loops, inspect scopes, and record CPU/heap performance snapshots:
```bash
# Start a debugger session and pause on first execution line
node --inspect-brk --import tsx index.ts

# Attaches debugger by process PID
node inspect -p <pid>

# Capture a heap snapshot for memory analysis
node --inspect scripts/run-vitest.mjs my-test.ts
```

### 3. Python debugpy Attachment (`skills/python-debugpy`)
Enables the agent to attach to local or remote Python applications using `debugpy` or `pdb` post-mortem handlers for unhandled exception capture:
```bash
# Spin up debugpy listening for headless remote DAP client attachment
python3 -m debugpy --listen 127.0.0.1:5678 --wait-for-client my_script.py

# Attach directly to an already running PID to inspect state
python3 -m debugpy --listen 127.0.0.1:5678 --pid <pid>
```

### 4. Frame Media Extraction (`skills/video-frames`)
Leverages `ffmpeg` wrappers to perform frame capture and thumbnails extraction from video streams for visual agent verification:
```bash
# Extract the first frame of a video for visual analysis
./scripts/frame.sh /path/to/video.mp4 --out /tmp/frame.jpg

# Grab frame at exactly 10 seconds offset
./scripts/frame.sh /path/to/video.mp4 --time 00:00:10 --out /tmp/frame-10s.jpg
```

### 5. Sprite Sheet Generation (`skills/gifgrep`)
Searches Tenor/Giphy via the Go-based `gifgrep` binary and samples animated GIF frames into single-image PNG sprite grids, reducing data transfer for visual review:
```bash
# Download and sample a GIF into a 3x3 frame sampling sheet
gifgrep sheet ./clip.gif --frames 9 --cols 3 -o sheet.png
```

### 6. Network Topology Diagnostics (`skills/node-connect`)
An advanced diagnostic runbook that automates network route verification for mobile nodes connecting to the local gateway (validating LAN configurations, Tailscale MagicDNS Serve/Funnel pipelines, and generating secure setup-code payloads).
```bash
# Generate the exact connection payload in JSON format
openclaw qr --json

# Approve a pending paired device
openclaw devices approve --latest
```

### 7. Physical Hardware Control (`skills/eightctl`)
Controls Sleep Pods (thermostats, schedules, and sleep diagnostics) through unofficial local hardware REST API clients written in Go:
```bash
# Read hardware sleep pod status
eightctl status

# Set target temperature
eightctl temp 21
```

---

## 💼 Engineering Workflows: Software & ML

In real-world production settings, OpenClaw operates as a highly automated sidekick for developers and machine learning practitioners, running tasks in background environments while engineers focus on complex architecture.

### 1. Software Engineering (SWE) Workflows

*   **Self-Healing CI & Triage**: 
    If a GitHub Actions build fails or tests flake, OpenClaw intercepts the webhook event. It retrieves the test failure output, maps the stack trace to the source file, and spins up an isolated, sandboxed background worker (via the `coding-agent` skill running Claude Code or Codex). The worker fixes the bug, validates the change locally, runs linters, and opens a self-correcting Pull Request.
*   **Visual QA & Emulator Testing**: 
    Using the `peekaboo` and `canvas` skills, the agent can launch a locally compiled iOS Simulator, Android Emulator, or Web page, perform custom GUI click flows, capture motion-aware screenshots, extract system logs, and post the test results (including visual proof) directly into engineering Slack channels.
*   **Away-from-Desk Hot Debugging**: 
    If a developer is away from their desk and gets paged about a stuck process, they can send a direct message on Telegram/Slack: `/debug-process --pid 8089`. OpenClaw attaches to the running process using the `node-inspect-debugger` or `python-debugpy` skill, captures the active call stacks, evaluates local scopes, dumps a diagnostic trace, and messages it back to the engineer.

### 2. Machine Learning (ML) Engineering Workflows

*   **Long-Running Training & VRAM Monitoring**: 
    ML engineers run long training runs (e.g., PyTorch loops) on headless remote GPU instances. OpenClaw runs a monitoring loop tracking metrics (Loss, Accuracy, Epochs, VRAM occupancy, and GPU temperatures). It sends scheduled status digests to the engineer, or triggers an urgent pager message if it detects exploding gradients (`NaN` loss) or an imminent Out-Of-Memory (`OOM`) exception—offering options to safely terminate or checkpoint the run via text response.
*   **Evaluation & Inference Pipeline Audits**: 
    During model evaluations, OpenClaw coordinates scripts to pass verification payloads through an active inference server. For computer vision or generative video pipelines, it uses the `video-frames` or `gifgrep` skills to extract sample inference predictions, compile them into lightweight, annotated 3x3 sprite sheets, and send them to the engineer for instantaneous visual human-in-the-loop evaluation.
*   **Local Inference Gateway Orchestration**: 
    Using health checks and local daemons, OpenClaw manages local LLM setups (like Ollama or vLLM instances). It dynamically balances model loading (shifting weights to/from system memory and GPU VRAM based on active usage), and auto-heals inference container crashes or memory leaks to maintain continuous local availability.

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
