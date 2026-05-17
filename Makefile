# Makefile — umas-wiki
# Run `make help` to see all available targets.

WIKI_DIR   := wiki
SOURCE_MAP := \
	1-git-and-github/01-version-control-basics.md:Git-Version-Control-Basics.md \
	1-git-and-github/02-using-git-cli.md:Git-Using-the-CLI.md \
	1-git-and-github/03-github-website-and-prs.md:Git-GitHub-Website-and-PRs.md \
	1-git-and-github/04-diffs-and-code-review.md:Git-Diffs-and-Code-Review.md \
	1-git-and-github/05-github-cli.md:Git-GitHub-CLI.md \
	2-agentic-coding/01-intro-to-agentic-coding.md:Agentic-Intro-to-Agentic-Coding.md \
	2-agentic-coding/02-effective-prompting.md:Agentic-Effective-Prompting.md \
	2-agentic-coding/03-repo-structure-for-agents.md:Agentic-Repo-Structure-for-Agents.md \
	2-agentic-coding/04-agents-md-deep-dive.md:Agentic-AGENTS-md-Deep-Dive.md \
	2-agentic-coding/05-creating-agent-skills.md:Agentic-Creating-Agent-Skills.md \
	2-agentic-coding/06-agentic-git-workflow.md:Agentic-Git-Workflow.md \
	2-agentic-coding/07-reviewing-agent-code.md:Agentic-Reviewing-Agent-Code.md \
	3-bazel/01-what-is-bazel.md:Bazel-What-is-Bazel.md \
	3-bazel/02-bazel-workspace-structure.md:Bazel-Workspace-Structure.md \
	4-ollama/01-intro-to-ollama.md:Ollama-Intro-to-Ollama.md \
	4-ollama/02-models-and-compute.md:Ollama-Models-and-Compute.md \
	5-docker-environments/01-docker-basics.md:Docker-Basics.md \
	5-docker-environments/02-bazel-dev-container.md:Bazel-Dev-Container.md \
	5-docker-environments/03-repo-structure-bazel-docker.md:Bazel-Docker-Repo-Structure.md \
	5-docker-environments/04-bazel-python-toolchains.md:Bazel-Python-Toolchains.md \
	5-docker-environments/05-multi-python-docker-bazel.md:Bazel-Multi-Python-Docker.md

.PHONY: help sync-wiki push-wiki push-all

help:
	@echo ""
	@echo "  make sync-wiki   Copy source markdown into the wiki/ submodule"
	@echo "  make push-wiki   Sync + commit + push the GitHub wiki"
	@echo "  make push-all    Commit + push this repo AND the wiki"
	@echo ""

## Copy all source markdown files into the wiki/ submodule with their wiki names
sync-wiki:
	@echo "Syncing source files into wiki/..."
	@cp README.md $(WIKI_DIR)/Home.md
	@for pair in $(SOURCE_MAP); do \
		src=$$(echo $$pair | cut -d: -f1); \
		dst=$$(echo $$pair | cut -d: -f2); \
		cp $$src $(WIKI_DIR)/$$dst; \
		echo "  $$src → wiki/$$dst"; \
	done
	@echo "Done."

## Sync files, commit, and push the wiki submodule to GitHub
push-wiki: sync-wiki
	@echo "Pushing wiki to GitHub..."
	@cd $(WIKI_DIR) && \
		git add . && \
		git diff --cached --quiet || git commit -m "sync: update wiki from source" && \
		git push origin master
	@echo "Wiki pushed."

## Commit + push the source repo, then sync and push the wiki
push-all: push-wiki
	@echo "Pushing source repo to GitHub..."
	@git add .
	@git diff --cached --quiet || git commit -m "chore: sync wiki submodule pointer"
	@git push origin master
	@echo "All done! Source repo and wiki are both up to date."
