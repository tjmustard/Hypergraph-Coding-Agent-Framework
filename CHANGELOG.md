# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **Git Tracking**: Removed `spec/compiled/` files (`architecture.yml`, `SuperPRD.md`) from Git tracking to respect `.gitignore` and framework standards.

### Removed
- **Integration Tests**: Deleted legacy integration tests in `tests/integration/` as part of codebase cleanup.

## [0.4.3] - 2026-05-17

### Added
- **`hyper-init` skill**: Scaffolds a new project with standard repository documentation from generic templates.
- **Project Templates**: Added generalized templates for `CHANGELOG.md`, `CITATION.cff`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `DEVELOPMENT.md`, `README.md`, and `SECURITY.md` in `.agents/schemas/project-templates/`.
- **Standard Repo Files**: Bootstrapped the Hypergraph framework repository itself with the new `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `DEVELOPMENT.md`, and `CITATION.cff` files based on the new templates.

### Changed
- **`hyper-document` skill**: Updated to include guidelines for maintaining the new standard repository documents in sync with the templates.
- **`README.md`**: Added `/hyper-init` instruction to the New Project setup guide.
- **`AGENTS.md`**: Registered `/hyper-init` in the master available skills index.
- **`GEMINI.md`**: Updated the list of available skills to include all 30 prefixed skills in alphabetical order, resolving stale legacy names.

## [0.4.2] - 2026-05-14

### Added
- **Enhanced `/hyper-publish` skill**: AI-proposes commit messages from CHANGELOG `[Unreleased]` + git diff; uses human-in-the-loop approval gates at each step (7 decision points); supports optional PR creation with auto-drafted descriptions from changelog.
- **Helper scripts for `/hyper-publish`**: 
  - `generate_commit_message.py` — reads CHANGELOG and recent commits to suggest subject/body
  - `generate_pr_description.py` — formats PR body from changelog with Summary and Test plan sections
  - `setup_permissions.py` — patches `.claude/settings.json` to pre-approve git/gh commands (eliminates per-invocation prompts)
- **Command Normalization**: Renamed `/clear` command to `/hyper-clear` to resolve naming conflict with Claude Code's built-in `/clear` command. All references updated across framework.
- **Examples and Templates for `/hyper-publish`**: 
  - `examples/example_commit_messages.md` — 5 real commit patterns from framework history
  - `examples/example_pr_description.md` — example PR description format
  - `resources/commit_template.md` — blank commit message template with guidelines
  - `resources/pr_description_template.md` — blank PR body template with section structure
- **`hyper-tutorial-generator` skill**: New `/hyper-tutorial-generator` command that converts existing integration tests or user-provided files into polished markdown tutorials via iterative LLM collaboration. Two input modes (Integration Test or User Files); section-by-section drafting with HITL approval gates; auto-scaffolds tutorial directory structure with supporting subdirectories (input_files/, output_files/, code_samples/, screenshots/).

### Changed
- **AskUserQuestion enforcement across 18 skills**: Standardized all structured user-facing choice prompts to explicitly invoke the `AskUserQuestion` tool instead of relying on freeform conversation turns. Affected skills: `hyper-sop` (phase selection), `hyper-troubleshooting` (symptom triage + follow-up), `hyper-update` (Replace/Merge/Skip gate + per-section merge approval), `hyper-execute` (re-implement confirmation + confidence gate), `hyper-resolve` (forced trade-off choices + NFR approval), `hyper-architect` (phase advance confirmation), `hyper-tutorial` (all 6 readiness checks), `hyper-deepdive` (integration question), `hyper-document` (version bump gate), `hyper-peer-review` (input method), `hyper-create-issue` (issue type + priority), `hyper-stitch-design` (style reference), `hyper-template-architect` (source document gate), `hyper-new-workflow` (name confirmation), `hyper-prompt-engineer` (output format + export), `hyper-co-research` (scoping gate), `hyper-consult-cto` (clarifying questions), `hyper-learning-opportunity` (depth selection + between-level readiness). Open-ended free-text interview questions (e.g., Architect phase questions) remain as freeform input.
- **`hyper-execute` and `hyper-audit` skills**: Enhanced with Haiku sub-agents for cost optimization. `/hyper-execute` delegates file pre-loading to a Haiku sub-agent (Step 2.5) before implementation. `/hyper-audit` delegates YAML reconciliation to a Haiku sub-agent (Phase 3) for mechanical node updates. Both include fallback logic to operate manually if sub-agent fails.
- **`install.sh`**: `spec/` directory is now scaffolded (empty subdirs created) instead of copied from framework. Ensures users start with clean slate for their own specification files, not framework's internal development history.
- **`.agents/memory/activeContext.md`**: Updated all references from `/clear` to `/hyper-clear`; noted command rename rationale.
- **`spec/compiled/architecture.yml`**: Updated context_clearing node to reference hyper-clear skill path and command name.
- **`.claude/settings.json`**: Added `"permissions": {"allow": ["Bash(git *)", "Bash(gh *)", "Bash(touch *)"]}` to pre-approve framework commands without per-invocation prompts.

### Removed
- **Deprecated `/clear` command**: Removed `.claude/commands/clear.md` command bridge and `.agents/skills/clear/` directory. Users must use `/hyper-clear` instead (same functionality, no naming conflict).

## [0.4.1] - 2026-05-04

### Added
- **`hyper-publish` skill**: New `/hyper-publish` command that updates `mtime` on all git-changed files to the current system time before committing and pushing. Supports `--dry-run` flag, optional CHANGELOG version promotion, and `$ARGUMENTS`-based commit message passthrough.
- **`hyper-update` skill**: Smart framework upgrade command with GPG signature verification, customization preservation, and backup management. Auto-updates framework files while guiding users through section-by-section merging of sensitive files (CLAUDE.md, AGENTS.md, IDE rules).
- **`hyper-recover` command**: File restoration from timestamped backups with meta-backup protection. List available backups and restore specific files from specific dates.
- **GPG Signature Verification**: Cryptographic verification of upstream commits before framework fetch. Fails-fast on invalid/missing signatures with installation guidance.
- **Timestamped Backup System**: ISO 8601 UTC backup directories (`.agents/.backup/YYYY-MM-DDTHH-MM-SSZ/`) with lazy creation, 30-day retention policy, and automatic cleanup.
- **Merge State Tracking**: JSON lock file (`.merge-in-progress.lock`) persists merge state across interrupts. Supports resume from last approved section and stale lock detection (>24 hours).
- **Backup Lifecycle Management**: Audit trail logging (JSON format) to `.agents/logs/hyper-update.log` with log rotation (1MB rotation, 10-file retention). Includes backup age warnings and meta-backup protection during recovery.

## [0.4.0] - 2026-05-03

### Added
- **Hybrid Model Orchestration**: Three-tier model routing system (Opus/Sonnet/Haiku) for cost-optimized skill execution. Routes simple deterministic tasks to Haiku (~70% cost reduction), complex reasoning to Opus, with fallback logic and comprehensive logging.
- **`model_router.py`**: Core module implementing model assignment logic, heuristic-based routing decisions, Opus fallback with alerting, and version compatibility checking.
- **`heuristic_classifier.py`**: YAML-based rule engine for automatic model tier suggestions during skill creation. Analyzes tool count, reasoning intensity, I/O complexity to recommend appropriate model.
- **`.agents/config/heuristic_rules.yaml`**: Declarative rule definitions for model tier classification with per-rule confidence scoring and model mapping (thinking tokens, costs, latency).
- **Skill Metadata System**: Per-skill `META.yml` configuration files in `.agents/skills/hyper-*/` with model assignment, version pinning, and override management.
- **`meta_loader.py`**: MetaLoader class for reading/validating skill metadata with schema validation and fallback defaults.
- **`override_manager.py`**: OverrideManager class for managing model assignment overrides with scope lifecycle (single_run/permanent), persistence, and terminal warning on activation.
- **Thinking Token Ceiling Enforcement**: Per-model defaults (Opus 20k, Sonnet 10k, Haiku 2k) with optional per-skill overrides via META.yml.
- **`thinking_token_monitor.py`**: ThinkingTokenMonitor class for resolving and logging thinking token ceilings with META.yml override support.
- **`ceiling_enforcer.py`**: CeilingEnforcer class for detecting ceiling breaches, emitting structured warnings with recovery suggestions (task splitting, temporary overrides), and tracking utilization metrics.
- **Output Token Budget Enforcement**: 50k output token ceiling with heuristic estimation formula (code_lines/40 + doc_pages*500 + test_cases*100).
- **`token_budget_checker.py`**: BudgetChecker class for validating estimated output tokens against 50k ceiling and suggesting task split points.
- **`token_budget_reconciler.py`**: TokenBudgetReconciler class for post-execution variance tracking (estimated vs. actual tokens) with investigation flag for >20% deviation.
- **Context Compaction Engine**: Automatic debate transcript compression preserving trade-off reasoning (both positions + resolution + risks), with interrupt recovery.
- **`compaction_engine.py`**: CompactionEngine class for extracting and compacting debate transcripts into Final Truth documents with archived full history links.
- **`interrupt_detector.py`**: InterruptDetector class for detecting incomplete compactions and auto-triggering compaction before /hyper-execute.
- **Context Clearing Mechanism**: Idempotent session context flushing via `/hyper-clear` command with state preservation (specs, metrics, performance data retained).
- **`clear` skill**: New `.agents/skills/hyper-clear/SKILL.md` implementing idempotent context clearing with post-audit hook integration.
- **Persistent Rules Migration**: Schema consolidation from `.agents/schemas/` into CLAUDE.md to reduce per-message token overhead (~10-15% reduction).
- **`final_truth_template.md`**: Schema for compacted debate output format with trade-off context preservation and archive links.
- **`META_template.md`**: Schema for per-skill metadata files with model assignment, version pinning, and override management guidance.
- **7 Integration Test Suites**: Comprehensive test documentation covering model routing, skill metadata, context compaction, thinking token ceilings, and token budget enforcement (46 tests total, all passing).

### Changed
- **`hyper-architect` skill**: Now routes to Opus by default; documents model assignment in execution logs.
- **`hyper-redteam` skill**: Now routes to Sonnet by default; logs thinking token usage separately from input/output.
- **`hyper-execute` skill**: Routes to Haiku by default; checks for missing compaction files and auto-compacts before proceeding; updated to support cost metrics collection.
- **`hyper-resolve` skill**: Automatically triggers context compaction after completion; outputs both full debate history and compacted Final Truth document.
- **`hyper-audit` skill**: Automatically triggers `/hyper-clear` after completion; updated to reconcile token-budget-enforcer node.
- **`CLAUDE.md`**: Added comprehensive "Schema Definitions" section with embedded SuperPRD, MiniPRD, and Hypergraph schemas (~800 lines consolidated); deprecated `.agents/schemas/` files with 6-week migration window (deadline: 2026-06-17).
- **`AGENTS.md`**: Updated skill descriptions for model routing, thinking token monitoring, and token budget enforcement; added `/hyper-clear` command documentation.
- **`spec/compiled/architecture.yml`**: Added 7 new nodes (context_clearing, context_compaction, model_router, skill_metadata, thinking_token_monitor, token_budget_enforcer, rules_migration); all marked clean and verified.
- **`.agents/memory/activeContext.md`**: Updated with Token Efficiency implementation status; all 7 MiniPRDs audited and archived.

### Removed
- Deprecated `.agents/schemas/` files (SuperPRD_Template.md, MiniPRD_template.md, hypergraph_schema.md) marked with deprecation headers; old files retained until 2026-06-17 for backward compatibility.

## [0.3.5] - 2026-03-15

### Changed
- **`hyper-execute` skill**: Added Step 1 — Memory Check. The skill now reads `.agents/memory/activeContext.md` before touching the MiniPRD. If the target MiniPRD is listed as complete or already audited, execution halts with a warning that explains the collision, provides the manual archive command as a fallback, and requires explicit user confirmation before proceeding.
- **`AGENTS.md`**: Updated `hyper-execute` description to reflect the memory check step.

## [0.3.4] - 2026-03-15

### Changed
- **`hyper-document` skill**: Expanded from a minimal 5-step outline to a full per-target documentation guide. Now covers `README.md`, `CHANGELOG.md`, `docs/MasterSOP.md`, `docs/Tutorial.md`, `docs/Troubleshooting.md`, `docs/Whitepaper.md`, `AGENTS.md`, `.agents/memory/` files, and `skills-info.md`. Each target includes explicit update triggers and style rules (tone, formatting, heading levels, prohibited language).
- **`AGENTS.md`**: Updated `hyper-document` skill description to reflect expanded scope.

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
