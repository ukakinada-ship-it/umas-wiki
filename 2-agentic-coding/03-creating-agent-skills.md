# Creating Skills for Agents

As you work with an AI agent, you will notice that certain tasks in your repository are repetitive, require highly specific context, or involve a complex sequence of steps that are unique to your workflow.

Instead of writing out a massive prompt every single time you want the agent to perform one of these tasks, you can create a "Skill."

## What is a Skill?
A Skill is essentially a documented procedure or a script that teaches the agent how to do something specific within your repository. It bridges the gap between the agent's general knowledge and your project's specialized needs.

## Why Create Skills?
- **Consistency:** Ensures the agent performs the task exactly the same way every time.
- **Efficiency:** Saves you from typing out long, repetitive prompts.
- **Scalability:** As your team grows, new human developers can just ask the agent to use a pre-defined skill, rather than having to learn the complex procedure themselves.

## How to Create a Skill

A skill is usually just a markdown file or a script placed in a designated directory (e.g., `.agent/skills/` or `docs/skills/`).

### Structure of a Good Skill File

A well-crafted skill file should contain:
1. **Name and Description:** What the skill does and when to use it.
2. **Prerequisites:** What state the repository needs to be in before running the skill.
3. **Step-by-Step Instructions:** Highly detailed, unambiguous instructions for the agent. Give the agent terminal commands to run, files to look at, and exact formats to output.
4. **Verification:** How the agent should verify it completed the task correctly.

### Example: A "Create New API Route" Skill

Imagine you have a complex Go backend. Creating a new route requires updating 4 different files. You could create a file `docs/skills/add-api-route.md`:

```markdown
# Skill: Add New API Route

## Description
Use this skill when the user asks to add a new REST API endpoint.

## Instructions
1. **Define the Handler:** Open `src/api/handlers.go`. Create a new handler function matching the requested endpoint.
2. **Register the Route:** Open `src/api/router.go`. Add the new handler to the main router configuration using the `gin` framework.
3. **Create the Request/Response Models:** Open `src/models/api_models.go`. Add the structs for the expected JSON payload and the response.
4. **Update Swagger:** Run the command `make swagger-gen` in the terminal to update the API documentation.

## Verification
- Run `make test-api` to ensure the router compiles and the basic tests pass.
- Verify the new endpoint is visible in the generated `docs/swagger.json` file.
```

## How to Use a Skill

When chatting with your agent (like Antigravity), you simply invoke the skill by referencing the file:

> *"Hey Antigravity, I need to add a new endpoint for `/users/login`. Please read the skill file at `docs/skills/add-api-route.md` and execute those instructions."*

The agent will read the file, absorb the specialized instructions, and execute the complex workflow seamlessly. This is the ultimate way to customize an agent to act as a senior developer on your specific codebase.
