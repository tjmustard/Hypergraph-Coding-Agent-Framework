# Hypergraph Coding Agent Framework — Agent Instructions

> **Cross-IDE manifest.** This file is injected as always-on context by Windsurf, Cursor,
> Roo Code, GitHub Copilot, and Zed. IDE-specific bridge files in `.claude/`, `.cursor/`,
> `.windsurf/`, `.clinerules/`, and `.roo/` extend this base with tool-specific overrides.
> For the human-facing usage guide, see `README.md`.

---

## Single Source of Truth

`.agents/` is the authoritative location for **all** skill, rule, schema, and script content.
All other IDE directories contain only thin bridge files that reference `.agents/`.

```
.agents/
├── skills/     # All skill/command definitions — one directory per skill
├── schemas/    # Immutable templates (MiniPRD, SuperPRD, hypergraph)
├── scripts/    # Deterministic state tools (hypergraph_updater.py, archive_specs.py)
├── rules/      # Always-on coding standards
└── memory/     # Project context files (activeContext, productContext, systemPatterns)

spec/
├── active/     # Working drafts — TEMPORARY, will be archived
├── compiled/   # Ground truth (SuperPRD, MiniPRDs, architecture.yml)
└── archive/    # Historical — BLOCKED from agent reads (.agentignore)

tests/
├── candidate_outputs/  # Unverified AI outputs — BLOCKED from agent reads
└── fixtures/           # Verified regression baselines
```

---

## System Mandates

### 1. Skill Invocation
When the user invokes a skill command (e.g., `/hyper-architect`, `/hyper-redteam`), read the
corresponding `.agents/skills/<name>/SKILL.md` and follow its instructions precisely.

To discover all available skills:
```
ls .agents/skills/
```

### 2. Autonomous Script Execution
Execute these deterministic Python scripts when mandated by a skill:

```bash
# Propagate blast radius after modifying code:
python .agents/scripts/hypergraph_updater.py spec/compiled/architecture.yml [node_id_1] [node_id_2]

# Flush active workspace after specification phase completes:
python .agents/scripts/archive_specs.py [Feature_Name]
```

Always verify the script completed successfully by checking the exit code and output.

### 3. State Management
- `spec/compiled/architecture.yml` is the **absolute ground truth** for project state.
- Write working drafts and reports to `spec/active/`.
- All generated specs must strictly follow the templates in `.agents/schemas/`.
- Read existing files before overwriting them.

### 4. Interactive Interviews
When acting as the Architect or Resolution Agent, enforce the **Pacing Loop**:
ask a MAXIMUM of **2 questions per turn**. Wait for the user's response before proceeding.

### 5. No Probabilistic Traversal
Never guess architectural dependencies. Always rely on `hypergraph_updater.py` output
to understand the blast radius before executing code modifications.

### 6. File Lifecycle Rules
- **Never** write to `spec/archive/` manually — use `archive_specs.py` exclusively.
- **Never** read from `spec/archive/` or `tests/candidate_outputs/` during agentic tasks
  (treated as blocked per `.agentignore`).
- **Never** edit `spec/compiled/architecture.yml` directly — use `/hyper-audit` or `/hyper-discover`.

### 7. Always-On Coding Rules
Apply the rules in `.agents/rules/` to all code generation:

| Rule File | Scope |
|---|---|
| `python.md` | Python style, type hints, architectural constraints |
| `security.md` | Input validation, secrets management, file system constraints |
| `testing.md` | Testing standards and patterns |
| `package-management.md` | Dependency management with `uv` |

---

## Available Skills

| Skill | Trigger | Phase | Description |
|---|---|---|---|
| `hyper-architect` | `/hyper-architect` | 1 | Requirements interview → Draft_PRD.md |
| `hyper-redteam` | `/hyper-redteam` | 1 | Adversarial analysis → RedTeam_Report.md |
| `hyper-resolve` | `/hyper-resolve` | 1 | Trade-off mediation → SuperPRD + MiniPRDs |
| `hyper-audit` | `/hyper-audit` | 2 | Code verification → reconciles architecture.yml |
| `hyper-execute` | `/hyper-execute` | 2 | Implements a MiniPRD with hypergraph update |
| `hyper-discover` | `/hyper-discover` | -1 | Scans codebase → initializes architecture.yml |
| `hyper-baseline` | `/hyper-baseline` | -1 | Reverse-engineers system → baseline SuperPRD |
| `hyper-sop` | `/hyper-sop` | any | Master SOP guide and phase orientation |
| `hyper-status` | `/hyper-status` | any | Living Master Plan snapshot |
| `hyper-consult-cto` | `/hyper-consult-cto` | pre-spec | CTO advisor for architectural decisions |
| `hyper-co-research` | `/hyper-co-research` | any | Peer-level AI research partner |
| `hyper-deepdive` | `/hyper-deepdive` | any | Exhaustive First Principles topic research |
| `hyper-create-skill` | `/hyper-create-skill` | any | Convert a prompt into a new skill |
| `hyper-new-workflow` | `/hyper-new-workflow` | any | Scaffold a new skill and IDE bridges |
| `hyper-document` | `/hyper-document` | any | Update docs after code changes |
| `hyper-session-update` | `/hyper-session-update` | any | Sync memory with session work |
| `hyper-refresh-memory` | `/hyper-refresh-memory` | any | Rebuild mental model from codebase |
| `hyper-troubleshooting` | `/hyper-troubleshooting` | any | Diagnose framework failure states |
| `hyper-tutorial` | `/hyper-tutorial` | any | Framework walkthrough for new users |
| `hyper-stitch-design` | `/hyper-stitch-design` | any | UI/UX → Design System specification |
| `hyper-prompt-engineer` | `/hyper-prompt-engineer` | any | Collaborative prompt design |
| `hyper-template-architect` | `/hyper-template-architect` | any | Reverse-engineer document into template |
| `hyper-peer-review` | `/hyper-peer-review` | any | Evaluate and triage peer review findings |
| `hyper-create-issue` | `/hyper-create-issue` | any | Format and file a GitHub issue |
| `hyper-learning-opportunity` | `/hyper-learning-opportunity` | any | Structured teaching on any concept |

Full skill instructions: `.agents/skills/hyper-<name>/SKILL.md`

---

## Framework Workflow (Quick Reference)

```
Phase -1 (Brownfield): /hyper-discover → /hyper-baseline
Phase  1 (Spec):       /hyper-architect → /hyper-redteam → /hyper-resolve → archive_specs.py
Phase  2 (Build):      /hyper-execute → hypergraph_updater.py → /hyper-audit
Phase  3 (Novel):      Human review → tests/fixtures/ → update MiniPRD
```

Each phase boundary requires a **fresh context window** to prevent cross-contamination
between adversarial agents (Red Team must not see Architect's conversation history).
