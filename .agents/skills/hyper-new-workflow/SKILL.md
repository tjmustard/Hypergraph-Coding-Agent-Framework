---
name: hyper-new-workflow
description: Converts a desired behavior, prompt, or idea into a properly formatted workflow file in the Hypergraph Coding Agent Framework. Use when the user wants to create a new slash command or workflow.
---

# New Workflow

This skill converts a description of desired agent behavior into a properly formatted workflow file, making it immediately available as a slash command.

## When to use this skill

- When the user asks to create a new "command" or "workflow" from an idea or prompt.
- When the user explicitly runs `/hyper-new-workflow [command_name] [description]`.
- After `/hyper-prompt-engineer` completes and the user chooses to export as a workflow.

## How to use it

1. **Gather Inputs**
   - Extract the command name and its intended behavior from the user's request.
   - If only a description is provided, suggest a short, hyphen-separated name (e.g., `code-review`, `api-design`).
   - Confirm a concise description for the frontmatter. Then use **ask-user** to confirm before drafting:

     ```
     Confirm the command name and description?

     - Option A: Looks good — proceed as suggested
     - Option B: Change the name — specify a different name (use Other)
     - Option C: Change the description — modify the description (use Other)
     ```

2. **Draft the Skill File**
   - Create the skill directory: `.agents/skills/<command-name>/`
   - Create the main file: `.agents/skills/<command-name>/SKILL.md`
   - **Mandatory frontmatter** — start the file with:
     ```yaml
     ---
     name: <command-name>
     description: <concise third-person description of what this skill does>
     trigger: /<command-name>
     ---
     ```
   - `name` **must exactly match the directory name** (lowercase letters, digits, and single hyphens; max 64 characters). Pi registers skills as `/skill:<name>` and Gemini CLI activates them by `name`, so a mismatch breaks invocation or collides with other skills.
   - **Structure the content** using the standard skill format:
     - `## When to use this skill` — trigger conditions
     - `## How to use it` — numbered steps for the agent to follow. Be explicit about agent actions, not just outcomes.

3. **Create IDE Bridge Files**
   Create a bridge in each harness bridge directory that exists in the project (skip any that are absent):
   - Create a thin bridge in `.claude/commands/<command-name>.md`:
     ```markdown
     ---
     description: "<description matching SKILL.md>"
     ---
     Read `.agents/skills/<command-name>/SKILL.md` and follow its instructions precisely.
     ```
   - Create a thin bridge in `.windsurf/workflows/<command-name>.md`:
     ```markdown
     ---
     description: "<description matching SKILL.md>"
     ---
     Read `.agents/skills/<command-name>/SKILL.md` and follow its instructions precisely.
     ```
   - No bridge is needed for Gemini CLI or Pi: both load `.agents/skills/` directly. Pi exposes the skill as `/skill:<command-name>`, and HCAF's `.pi/extensions/hcaf-commands.ts` also accepts `/<command-name>` for any `hyper-` skill.

4. **Verify and Notify**
   - Confirm all files are well-formed with valid YAML frontmatter.
   - Run `python .agents/scripts/validate_skills.py` and fix any errors it reports (name/directory mismatch, missing description, harness-specific tool names).
   - Notify the user: "The `/<command-name>` skill is ready. The SKILL.md is the source of truth in `.agents/skills/<command-name>/`, with IDE bridges in the harness directories listed above."
