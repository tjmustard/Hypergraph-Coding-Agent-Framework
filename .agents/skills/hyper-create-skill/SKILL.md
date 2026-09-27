---
name: hyper-create-skill
description: Converts an agentic prompt or Gemini Gem into a new structured skill for the Hypergraph Coding Agent Framework. Use this skill when asked to create a new skill from a prompt, gem, or idea.
---

# Create Skill

Follow these steps to predictably convert a Gemini Gem or generic agentic prompt into a properly formatted structural skill for the Hypergraph Coding Agent Framework.

## When to use this skill
- When the user provides an agentic prompt, a "Gemini Gem", or a raw textual description and asks you to create a "skill" out of it.
- When the user runs the `/hyper-create-skill` slash command.

## How to use it

1. **Gather Inputs**: 
   - Ensure you have the full content of the agentic prompt / Gemini Gem.
   - Determine a short, hyphen-separated name for the skill (e.g., `code-review` or `api-design`). Framework skills use the `hyper-` prefix (e.g., `hyper-code-review`).
   - Determine a concise, third-person description of what the skill does (e.g., "Generates unit tests for Python code using pytest conventions.").

2. **Create the Directory Structure**:
   - Create the primary skill folder at `.agents/skills/<skill-name>/` (Workspace scope) or a global skills directory: `~/.gemini/antigravity/skills/<skill-name>/` (Antigravity) or `~/.agents/skills/<skill-name>/` (Pi and other Agent Skills harnesses). Default to workspace scope unless otherwise specified.
   - Create the standard optional subdirectories:
     - `scripts/` (for helper scripts)
     - `examples/` (for reference implementations)
     - `resources/` (for templates and assets)

3. **Draft the SKILL.md File**:
   - Create the main instruction file at the root of the skill folder: `SKILL.md`.
   - **Mandatory Frontmatter**: Start the file with the strict YAML frontmatter exactly as shown in this skill's `resources/SKILL_TEMPLATE.md`. The `name` field **must exactly match the skill directory name** (lowercase letters, digits, and single hyphens; max 64 characters), and `description` is required (max 1024 characters). Pi and Gemini CLI identify skills by `name`.
   - **Structure the Content**: Adapt the prompt into the standard markdown format using the template as a guide. Ensure you include the `## When to use this skill` and `## How to use it` sections.

4. **Organize and Create Auxiliary Files**:
   - Identify if the input prompt/Gem includes secondary materials (scripts, examples, JSON schemas, templates, etc.).
   - Create any identified script files in the `scripts/` subdirectory (ensure executable permissions if applicable).
   - Create any identified example files in the `examples/` subdirectory under the new skill.
   - Create any identified template or asset files in the `resources/` subdirectory under the new skill.
   - Explicitly reference these auxiliary files from within the newly generated `SKILL.md` file using relative paths or explicit instructions.

5. **Verify and Notify**: 
   - Confirm the file is well-formed, valid YAML is used in the frontmatter, and all necessary directories and inputs have been written to disk.
   - Read the examples provided in this skill's `examples/` folder if you need a reference on how to format the new skill.
   - Run `python .agents/scripts/validate_skills.py` and fix any frontmatter errors it reports.
   - Notify the user that the skill has been correctly scaffolded. Harnesses that read `.agents/skills/` directly (Pi as `/skill:<name>`, Gemini CLI via `activate_skill`) discover it automatically. For `/<name>` slash-command bridges in Claude Code, Windsurf, and Pi (`.pi/prompts/`), follow step 3 of `.agents/skills/hyper-new-workflow/SKILL.md`.
