# Introduction to Ollama

While AI models like GPT-4 or Claude are incredibly powerful, they are hosted in the cloud. This means you have to pay for API usage, you need an internet connection, and you must send your potentially private code or data to a third-party server.

**Ollama** solves this by letting you run Large Language Models (LLMs) entirely locally on your own hardware.

## What is Ollama?
Ollama is a lightweight, open-source application that makes it incredibly easy to download, install, and run LLMs on your Mac, Linux, or Windows machine.

Think of it like Docker, but specifically designed for AI models.

## Why run models locally?
1. **Privacy & Security:** Your data never leaves your machine. This is crucial for working on proprietary company codebases where sending data to an external API is a security risk.
2. **Cost:** Running models locally is entirely free (after the initial hardware cost). You don't pay per token.
3. **Offline Capability:** You can code and get AI assistance even on an airplane or without internet access.
4. **Customization:** You can easily fine-tune or run specialized, uncensored models that might not be available via commercial APIs.

## How it works
Ollama acts as a background service. It exposes a local API (usually at `http://localhost:11434`) that perfectly mimics the OpenAI API structure.

This means that almost any agentic coding tool or UI interface (like Antigravity, Continue.dev, or Open WebUI) that can connect to an API can easily be pointed to your local Ollama instance instead!

## Getting Started with Ollama

Running your first local model is shockingly simple.

1. **Install:** Download Ollama from `ollama.com` or install via command line (e.g., `curl -fsSL https://ollama.com/install.sh | sh`).
2. **Run a Model:** Open your terminal and type:
   ```bash
   ollama run llama3
   ```
3. **Chat:** Ollama will download the model weights (if you don't have them yet) and immediately drop you into a command-line chat interface where you can talk to the AI.

In the next section, we'll look at the different types of models available and what kind of computer hardware you actually need to run them effectively.
