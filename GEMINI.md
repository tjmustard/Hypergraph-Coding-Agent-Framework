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

Available skills: `hyper-architect`, `hyper-audit`, `hyper-baseline`, `hyper-clear`, `hyper-co-research`,
`hyper-consult-cto`, `hyper-create-issue`, `hyper-create-skill`, `hyper-deepdive`, `hyper-discover`,
`hyper-document`, `hyper-execute`, `hyper-init`, `hyper-learning-opportunity`, `hyper-new-workflow`,
`hyper-peer-review`, `hyper-prompt-engineer`, `hyper-publish`, `hyper-redteam`, `hyper-refresh-memory`,
`hyper-resolve`, `hyper-session-update`, `hyper-sop`, `hyper-status`, `hyper-stitch-design`,
`hyper-template-architect`, `hyper-troubleshooting`, `hyper-tutorial`, `hyper-tutorial-generator`,
`hyper-update`

---

## Schema Definitions & Migration Notice

**Note:** All schema definitions (SuperPRD, MiniPRD, architecture.yml) and migration rules have been centralized in `AGENTS.md` to ensure a single source of truth across all agent IDE integrations. Please refer to `AGENTS.md` for these persistent rules.
