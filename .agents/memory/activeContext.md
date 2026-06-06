
# Active Context
## Purpose
This file updates dynamically after *every task completion*. It captures the "Now" of the project: what was just done, what is currently being worked on, and any immediate blockers or open questions.

## Usage
- Agent writes here after completing a task.
- Agent reads this *first* to understand where to pick up.

## Current Sprint Goal
- [x] Implement /hyper-clear command for context flushing between feature cycles
- [x] Implement context compaction engine for trade-off preservation
- [x] Implement model routing matrix and heuristic classifier
- [x] Implement persistent rules migration to CLAUDE.md
- [x] Implement skill metadata system
- [x] Implement /hyper-publish skill for timestamp-safe git publishing (v0.4.1)

## Session State
- session_cleared: true
- cleared_at: 2026-05-04T22:22:00Z
- cleared_by: /hyper-clear command (manual invocation)
- clear_command_available: true
- idempotency_tracking: enabled

## Recent Decisions
- Implemented /hyper-clear as a skill-based command that guides users to start new conversation windows
- State tracked via activeContext.md for idempotency verification
- Post-audit hook integration documented in SKILL.md
- Renamed /clear to /hyper-clear to resolve naming conflict with Claude Code built-in /clear command

## Implementation & Audit Status ✅ COMPLETE
- [x] MiniPRD_ClearingMechanism.md → audited & archived
- [x] MiniPRD_ContextCompaction.md → audited & archived
- [x] MiniPRD_ModelRoutingMatrix.md → audited & archived
- [x] MiniPRD_PersistentRulesMigration.md → audited & archived
- [x] MiniPRD_SkillMetadata.md → audited & archived (4 user stories, 7/7 tests)
- [x] MiniPRD_ThinkingTokenCeilings.md → audited & archived (3 user stories, 7/7 tests)
- [x] MiniPRD_TokenBudgetEnforcement.md → audited & archived (3 user stories, 6/6 tests, token_budget_enforcer node marked clean)

**SuperPRD Status:** All 7 MiniPRDs audited and archived ✅
- MiniPRD_ClearingMechanism_AUDITED.md
- MiniPRD_ContextCompaction_AUDITED.md
- MiniPRD_ModelRoutingMatrix_AUDITED.md
- MiniPRD_PersistentRulesMigration_AUDITED.md
- MiniPRD_SkillMetadata_AUDITED.md
- MiniPRD_ThinkingTokenCeilings_AUDITED.md
- MiniPRD_TokenBudgetEnforcement_AUDITED.md

**v0.4.0 Release Complete** ✅
All documentation updated (README.md, CHANGELOG.md, AGENTS.md)
Framework ready for production deployment with hybrid model orchestration and cost optimization

**v0.4.2 Release Complete** ✅
- [x] Enhanced `/hyper-publish` with AI-proposed commit messages and PR creation
- [x] Renamed `/clear` → `/hyper-clear` to resolve naming conflict
- [x] Updated `install.sh` to scaffold spec/ instead of copy
- [x] Added pre-approved git/gh commands to settings.json
- [x] Updated README.md, CHANGELOG.md, AGENTS.md, architecture.yml
- [x] Created `/hyper-tutorial-generator` skill for markdown tutorial generation
- [x] Integrated Haiku sub-agents into `/hyper-execute` (Step 2.5) and `/hyper-audit` (Phase 3) for cost optimization
- [x] Updated documentation for all v0.4.2 changes
- [x] Enforced `AskUserQuestion` tool across 18 skills (structured choice prompts replace freeform conversation turns)

**v0.4.3: Standardizing Repository Documentation Framework** 🚀
- [x] Convert repository documentation (README, CHANGELOG, CITATION, CODE_OF_CONDUCT, CONTRIBUTING, DEVELOPMENT, SECURITY) into reusable, generalized templates in `.agents/schemas/project-templates/`
- [x] Implement `/hyper-init` skill for project bootstrapping via user interviews
- [x] Bootstrap the framework's own repo with standard templated files
- [x] Merge IDE configs (`GEMINI.md`, `CLAUDE.md`, etc.) into centralized `AGENTS.md` standard
- [x] Update `/hyper-document` skill to enforce baseline standards and keep templates in sync
- [x] Restructure framework's core `README.md` to follow template style and layout
- [x] Run `/hyper-document` to finalize and verify the entire documentation suite

**hyper-update Integration Sprint** ✅ COMPLETE
- [x] MiniPRD_hyper-update-upstream-verification: GPG signature verification, backup cleanup, audit logging (audited & archived)
- [x] MiniPRD_hyper-update-merge-engine: Section parsing, diff display, approval loop (audited & archived)
- [x] MiniPRD_hyper-update-recovery: Backup management, `/hyper-recover` command (audited & archived)
- [x] MiniPRD_hyper-update-integration: CLI bridge, documentation updates (audited & archived)

## Files Modified
- Created: `.agents/schemas/project-templates/` (standard doc templates)
- Created: `.agents/skills/hyper-init/` (project bootstrapping skill)
- Created: `CITATION.cff`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `DEVELOPMENT.md`, `SECURITY.md` (bootstrapped from templates)
- Updated: `README.md` (restructured to match template style)
- Updated: `CHANGELOG.md` (documented v0.4.3 changes)
- Updated: `AGENTS.md` (registered /hyper-init skill, centralized IDE specs, embedded schemas)
- Updated: `CLAUDE.md`, `GEMINI.md` (linked to authoritative AGENTS.md)
- Updated: `.agents/skills/hyper-document/SKILL.md` (integrated standard repo templates rules)
- Updated: `skills-info.md` (added available skills index table)
- Updated: `.agents/memory/activeContext.md` (sprint state tracking)
**Maintenance & Cleanup** (2026-05-19)
- [x] Removed `spec/compiled/` files from Git tracking to respect framework standards
- [x] Deleted legacy integration tests in `tests/integration/`
- [x] Updated `.gitignore` and `CHANGELOG.md`

## Files Modified
- Updated: `.gitignore`
- Updated: `CHANGELOG.md`
- Updated: `.agents/memory/activeContext.md`
- Deleted: `tests/integration/test_*.md`

---

**v0.5.0: Dynamic Workflow & Parallel Execution Engine** ✅ COMPLETE
- [x] MiniPRD_Dynamic_Orchestrator.md → audited & archived (2026-06-03)
- [x] MiniPRD_Autonomous_Resolution.md → implemented & tested
- [x] MiniPRD_Provenance_Integration.md → implemented & tested
- [x] Install templates separation → `.agents/install-templates/` created
- [x] architecture.yml reconciled — all 6 dirty nodes → clean
- [x] CHANGELOG.md & README.md updated, v0.5.0 documented

## Files Modified (v0.5.0 sprint)
- Created: `.agents/scripts/hyper_orchestrator.py` — parallel fan-out + rebase pipeline + FAILED_WORKFLOWS
- Created: `.agents/scripts/hyper_daemon.py` — orchestrated/standalone loop, stop_reason guard, spec drift
- Created: `.agents/scripts/hyper_fix.py` — triangulated fix prompt, spec drift detector, ORACLE_FAILURE cap
- Created: `.agents/scripts/hyper_resolve_conflict.py` — confidence gate ≥85, whitelist, syntax check
- Created: `.agents/scripts/semantic_graph_merger.py` — deterministic YAML merge, schema validation, locking
- Patched: `.agents/scripts/hypergraph_updater.py` — provenance staging write/merge/cleanup subcommands
- Patched: `.agents/scripts/hyper_update_core.py` — SENSITIVE_FILE_UPSTREAM_SOURCES for install templates
- Created: `.agents/install-templates/CLAUDE.md`, `AGENTS.md`, `GEMINI.md` — project-framed install versions
- Updated: `install.sh` — FILE_SOURCE_OVERRIDE map routes IDE files to install-templates/
- Updated: `.agents/skills/hyper-architect/SKILL.md` — schema reference CLAUDE.md → AGENTS.md
- Updated: `spec/compiled/architecture.yml` — 6 dirty nodes reconciled to clean
- Created: `tests/integration/test_dynamic_orchestrator.py` (10 tests, all passing)
- Created: `tests/integration/test_autonomous_resolution.py` (10 tests, all passing)
- Created: `tests/integration/test_provenance_integration.py`
- Created: `spec/active/FAILED_WORKFLOWS.md` — initial empty report file
- Created: `.provenance_staging/.gitkeep` — staging directory
- Updated: `README.md`, `CHANGELOG.md` — v0.5.0 documentation

## Post-v0.5.0 Skill Additions (Unreleased)
- [x] `hyper-contextualize` skill — audits/fixes HACF framing in installed projects
- [x] `hyper-handoff` skill — compacts conversation into OS-temp handoff document
- [x] `hyper-grill-docs` skill — domain sharpening with CONTEXT.md + ADR inline updates
- [x] `hyper-architect` — redesigned to grill-me mode (1 question/turn, recommended answers, codebase-first, depth-first)
- [x] `install.sh` banners — fixed stale command names, added /hyper-contextualize suggestion
- [x] CHANGELOG.md [Unreleased] section updated with all above
- [x] README.md — skill count updated (29→33), slash command list updated, architect SOP description updated

## Files Modified (post-v0.5.0)
- Created: `.agents/skills/hyper-contextualize/` (SKILL.md, META.yml)
- Created: `.agents/skills/hyper-handoff/` (SKILL.md, META.yml)
- Created: `.agents/skills/hyper-grill-docs/` (SKILL.md, META.yml, CONTEXT-FORMAT.md, ADR-FORMAT.md)
- Created: `.claude/commands/hyper-contextualize.md`, `hyper-handoff.md`, `hyper-grill-docs.md`
- Updated: `.agents/skills/hyper-architect/SKILL.md` — grill-me interview mode
- Updated: `AGENTS.md`, `.agents/install-templates/AGENTS.md`, `skills-info.md` — new skill rows

**v0.5.1 Release: Domain Sharpening & Handoff Skills** ✅ COMPLETE (2026-06-06)
- [x] `hyper-contextualize` — audits/fixes HACF framing in installed projects
- [x] `hyper-handoff` — compacts conversation into OS-temp handoff document (adapted from mattpocock/skills)
- [x] `hyper-grill-docs` — domain sharpening with CONTEXT.md + ADR inline updates (adapted from mattpocock/skills)
- [x] `hyper-architect` — grill-me redesign (1 question/turn, recommended answers, codebase-first, depth-first)
- [x] `install.sh` banners — fixed stale command names, added /hyper-contextualize suggestion
- [x] ATTRIBUTION.txt files in hyper-handoff/ and hyper-grill-docs/
- [x] README.md Acknowledgements section (Zevi Arnovitz, Matt Pocock)
- [x] CHANGELOG.md v0.5.1 promoted from [Unreleased]
- [x] README.md badge updated to v0.5.1

## Next Steps
- Consider adding `hyper_orchestrator.py` invocation documentation to `docs/`
