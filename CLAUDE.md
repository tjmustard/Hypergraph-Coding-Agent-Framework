# Claude Code Integration Guide

> **For Human Developers:** See `README.md` for the complete usage guide, available slash
> commands, and setup instructions.

---

## For Claude Code: System Mandates

Read `AGENTS.md` for the full framework system mandates that apply to all IDEs.

**Claude Code-specific overrides and additions:**

### Tool Names
When skills say "read/write/run/edit a file," use these Claude Code tools:

| Action | Tool |
|---|---|
| Read a file | **Read** tool |
| Write a file | **Write** tool |
| Edit a file | **Edit** tool |
| Run a shell command | **Bash** tool |
| Ask the user a question | **AskUserQuestion** tool |
| Search file patterns | **Glob** tool |
| Search file contents | **Grep** tool |

### Skill Invocation
Skills are available as slash commands in `.claude/commands/`. Each command is a thin bridge
that reads its corresponding `.agents/skills/hyper-<name>/SKILL.md`. When the user invokes a command,
the skill file provides the full instructions.

### Task Tracking
For any task involving 3 or more steps, use the built-in task tools **before** starting work:
- **TaskCreate** — create tasks with clear subjects
- **TaskUpdate** — mark `in_progress` when starting, `completed` when done
- **TaskList** — check overall progress

### Context Window Management
When a skill instructs you to "open a new context window": **complete the current agent turn**,
then inform the user to start a new conversation thread for the next phase. This prevents
cross-contamination between adversarial agents (the Red Team must not see the Architect's
conversation history).
