# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2026-02-22

### Added
- **Gemini CLI Integration**: Added `GEMINI.md` to automate Hypergraph framework orchestration using Gemini CLI's Skills and autonomous tool execution.
- **Maintainability Tools**: Added `.gitignore` to prevent project-specific draft specifications from being accidentally committed.
- **Standard Dependency Management**: Added `requirements.txt` to replace manual `pip install` instructions.
- **Project Tracking**: Added `CHANGELOG.md` to record development history and architectural shifts.
- **Tutorial Visibility**: Updated `README.md` to point more clearly to the `Tutorial.md` and `GEMINI.md` guides.

### Changed
- **Documentation**: Enhanced `README.md` to include references to Gemini CLI's native multi-agent capabilities.
- **Workflow**: Updated the repository's core mandates to prioritize automated state management when operated by Gemini CLI.

## [0.2.0] - 2026-02-21

### Added
- Created `skills-info.md` to document the purpose and usage of each agent skill.
- Created `baseline` skill directory (`.agents/skills/baseline/SKILL.md`).
- Created `discover` skill directory (`.agents/skills/discover/SKILL.md`) with its own `hypergraph_schema.md` and `hypergraph_updater.py`.

### Changed
- **Major Skill Directory Refactor**: Transitioned from flat markdown files in `.agents/skills/` to dedicated skill folders (e.g., `.agents/skills/architect/SKILL.md`).
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
