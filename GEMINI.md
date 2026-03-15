# Gemini CLI Integration Guide

> **For Human Developers:** See `README.md` for the complete usage guide and setup
> instructions.

---

## For Gemini CLI: System Mandates

Read `AGENTS.md` for the full framework system mandates that apply to all IDEs.

**Gemini CLI-specific overrides and additions:**

### Tool Names
When skills say "read/write/run/edit a file," use these Gemini CLI tools:

| Action | Tool |
|---|---|
| Read a file | `read_file` tool |
| Write a file | `write_file` tool |
| Run a shell command | `run_shell_command` tool |
| Ask the user a question | `ask_user` tool |
| List directory contents | `list_directory` tool |

### Skill Invocation
Activate skills via the `activate_skill` tool, using the skill names defined in
`.agents/skills/`. Each skill directory contains a `SKILL.md` with full instructions.

Available skills: `architect`, `redteam`, `resolve`, `audit`, `execute`, `discover`,
`baseline`, `sop`, `status`, `consult-cto`, `co-research`, `deepdive`, `create-skill`,
`new-workflow`, `document`, `session-update`, `refresh-memory`, `troubleshooting`,
`tutorial`, `stitch-design`, `prompt-engineer`, `template-architect`, `peer-review`,
`create-issue`, `learning-opportunity`
