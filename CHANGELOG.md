# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.3] - 2026-03-15

### Changed
- **`hyper-audit` skill**: Added Phase 4 — MiniPRD Archival. After a successful audit, the MiniPRD is automatically moved from `spec/compiled/` to `spec/archive/` (renamed with `_AUDITED` suffix). Since `spec/archive/` is blocked by `.agentignore`, the completed MiniPRD no longer surfaces in subsequent `/hyper-execute` runs.
- **`hyper-execute` skill**: Added a note in the halt/report step informing developers that a passing audit will archive the MiniPRD automatically.

## [0.3.2] - 2026-03-15

### Changed
- **`README.md`**: Documented the `hyper-` naming convention — added explanations in the directory structure section (`.agents/skills/`, `.claude/commands/`) and a callout block in the Setup section clarifying that the prefix prevents collisions with project-specific skills and commands.

## [0.3.1] - 2026-03-15

### Changed
- **Skill namespace prefix**: All 25 skills renamed from `<name>` to `hyper-<name>` to prevent collisions with project-specific skills in consumer repos.
  - `.agents/skills/<name>/` → `.agents/skills/hyper-<name>/`
  - `.claude/commands/<name>.md` → `.claude/commands/hyper-<name>.md`
  - `.windsurf/workflows/<name>.md` → `.windsurf/workflows/hyper-<name>.md`
  - All slash command invocations updated (`/architect` → `/hyper-architect`, etc.)
  - All references in `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `README.md`, rule bridges, and `docs/` updated accordingly.

## [0.3.0] - 2026-03-15

### Added
- **Multi-IDE Support**: Full support for Windsurf, Cursor, Cline, Roo Code, GitHub Copilot, and Zed in addition to existing Claude Code and Gemini CLI/Antigravity support.
- **`AGENTS.md`**: New universal cross-IDE always-on manifest at the repository root. Consumed natively by Windsurf, Cursor, Roo Code, GitHub Copilot, and Zed.
- **`.windsurf/`**: New directory with rule bridges (`rules/`) and workflow bridges (`workflows/`) — one thin file per skill and coding standard.
- **`.cursor/rules/`**: New directory with `.mdc` rule bridges using Cursor's YAML frontmatter (`globs`, `alwaysApply`) for contextual activation.
- **`.clinerules/`**: New directory with plain markdown rule bridges for Cline.
- **`.roo/`**: New directory with mode-aware rule bridges (`rules/` for all modes, `rules-code/` for code mode only).
- **`sop` skill**: Created missing `.agents/skills/hyper-sop/SKILL.md` — the skill existed as a `.claude/commands/` entry but had no backing SKILL.md.
- **`install.sh` IDE selection menu**: Interactive numbered menu to select which IDE(s) to install support for; supports `--ides=` flag and `-y` for non-interactive installs.
- **`install.sh` `.gitignore` prompt**: After installation, offers to append installed IDE-specific paths to the project's `.gitignore`.

### Changed
- **Zero-duplication architecture**: `.agents/skills/*/SKILL.md` is now the single source of truth. All IDE directories (`.claude/commands/`, `.windsurf/workflows/`, etc.) contain only 4-line thin bridge files that reference the central skill.
- **`.claude/commands/`**: All 25 command files converted to thin bridges. Previously, 7 files (architect, redteam, resolve, audit, discover, baseline, sop) contained full duplicate skill content.
- **`CLAUDE.md`**: Slimmed from ~103 lines to ~40 lines. Removed duplicate content now covered by `AGENTS.md`; retained only Claude Code-specific tool name overrides and task tracking mandate.
- **`GEMINI.md`**: Same treatment as `CLAUDE.md` — slimmed to Gemini CLI-specific tool overrides only, references `AGENTS.md` for shared content.
- **`.agents/skills/hyper-new-workflow/SKILL.md`**: Fixed scaffold target from `.agents/workflows/` to `.agents/skills/*/SKILL.md` to prevent regenerating the removed duplication layer.
- **`.agents/skills/hyper-architect/SKILL.md`**: Fixed truncated Phase 5 — content was cut off mid-sentence; full action steps restored.
- **`install.sh`**: Rewrote with modular `IDE_DEFS` array, upgrade-mode detection, migration block, and per-component update prompts.
- **`README.md`**: Full rewrite to document the no-duplication architecture, all new IDE bridge directories, per-IDE integration sections, and updated install.sh features.

### Removed
- **`.agents/workflows/`**: Entire directory deleted. Was a third redundant copy of skill content (older and less complete than `.agents/skills/`). All 17 workflow files removed.

## [0.2.3] - 2026-02-22

### Changed
- **Workflows**: Replaced the automated git-history approach in the `/hyper-document` workflow with an explicit, interactive user prompt for semantic versioning.
- **Workflows**: Upgraded the `/hyper-document` workflow to gracefully structure and label stamped release sections derived from the `[Unreleased]` block.

## [0.2.2] - 2026-02-22

### Added
- **Agent Resources**: Added new directories `.agents/memory/`, `.agents/rules/`, and `.agents/schemas/` housing agent rule templates and schema templates (`DESIGN_Template.md`, `PRD_Template.md`, `plan_Template.md`, `todo_Template.md`).
- **Workflows**: Duplicated and formatted agent skills into the `.agents/workflows/` directory for Antigravity integration (e.g., `code-auditor.md`, `consult-cto.md`, `create-issue.md`, `create-plan.md`, `execute.md`, `explore.md`, `review.md`, etc.).
- **Gemini CLI Integration**: Added `GEMINI.md` to automate Hypergraph framework orchestration using Gemini CLI's Skills and autonomous tool execution.
- **Maintainability Tools**: Added `.gitignore` to prevent project-specific draft specifications from being accidentally committed.
- **Standard Dependency Management**: Added `requirements.txt` to replace manual `pip install` instructions.
- **Project Tracking**: Added `CHANGELOG.md` to record development history and architectural shifts.
- **Tutorial Visibility**: Updated `README.md` to point more clearly to the `Tutorial.md` and `GEMINI.md` guides.

### Changed
- **Documentation Structure**: Moved `MasterSOP.md`, `Troubleshooting.md`, `Tutorial.md`, and `Whitepaper.md` to a new `docs/` directory, updating `README.md` links accordingly.
- **Documentation**: Enhanced `README.md` to include references to Gemini CLI's native multi-agent capabilities.
- **Workflow**: Updated the repository's core mandates to prioritize automated state management when operated by Gemini CLI.
- **Workflows**: Refined formatting of agent workflows in `.agents/workflows/` by adding standard titles and updating legacy PRD references to the new `SuperPRD` format.
- **Documentation**: Updated the `/hyper-document` workflow to explicitly mandate `README.md` updates alongside the `CHANGELOG.md`.
- **Documentation**: Updated `README.md` to document the `.agents/workflows/` directory.

### Removed
- **Archived Workflows**: Deleted the obsolete `.agents/workflows/archive/` directory.
- **Workflows**: Deleted obsolete `.agents/workflows/review.md` in favor of newer workflow structures.


## [0.2.0] - 2026-02-21

### Added
- Created `skills-info.md` to document the purpose and usage of each agent skill.
- Created `baseline` skill directory (`.agents/skills/hyper-baseline/SKILL.md`).
- Created `discover` skill directory (`.agents/skills/hyper-discover/SKILL.md`) with its own `hypergraph_schema.md` and `hypergraph_updater.py`.

### Changed
- **Major Skill Directory Refactor**: Transitioned from flat markdown files in `.agents/skills/` to dedicated skill folders (e.g., `.agents/skills/hyper-architect/SKILL.md`).
- Copied necessary resources (`hypergraph_schema.md`, `MiniPRD_template.md`) and scripts (`archive_specs.py`, `hypergraph_updater.py`) directly into their respective skill directories to make them self-contained.
- Overhauled `README.md` to reflect the new directory structure and refined workflow.
- Updated `MasterSOP.md`, `Tutorial.md`, `Troubleshooting.md`, and `Whitepaper.md` to align with the new structure.

### Removed
- Redundant `Coding_4_Whitepaper.md` file.
- Archived the old flat workflow files into `.agents/workflows/archive/`.

## [0.1.0] - 2026-02-21

### Added
- Fleshed out `.agents/workflows/` by adding detailed markdown files for `architect.md`, `audit.md`, `baseline.md`, `discover.md`, `redteam.md`, and `resolve.md`.
- Added new workflow instructions to `MasterSOP.md`.

### Changed
- Renamed the `.agent` directory to `.agents`.

## [0.0.1] - 2026-02-21

### Added
- Initial commit establishing the core Hypergraph Coding Agent Framework.
- `.agentignore` to prevent AI context collapse.
- Core documentation: `README.md`, `Whitepaper.md`, `Coding_4_Whitepaper.md`, `MasterSOP.md`, `Tutorial.md`, and `Troubleshooting.md`.
- `MiniPRD_template.md` and `hypergraph_schema.md` schemas.
- Deterministic Python scripts: `archive_specs.py` and `hypergraph_updater.py`.
- Initial agent skill prompts: `architect.md`, `audit.md`, `redteam.md`, and `resolve.md`.
- Directory structure for specifications (`spec/active/`, `spec/archive/`, `spec/compiled/`) and tests (`tests/candidate_outputs/`, `tests/fixtures/`) with `.gitkeep` files.
