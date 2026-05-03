# Hypergraph Coding Agent Framework (Coding 4.0)

A rigorously structured framework designed to solve the **Specification Alignment Problem** in AI-assisted coding. The **Hypergraph Coding Agent Framework** is the definitive implementation of the **Coding 4.0** paradigm, shifting the developer's role from a writer of syntax to an architect of intent. By decoupling probabilistic reasoning from deterministic state management, it prevents context collapse and hallucinations in complex systems.

---

## 🏗️ Core Architectural Pillars

The Hypergraph Framework abandons the standard "Prompt Zero" approach in favor of a rigorous, multi-resolution specification pipeline:

1.  **Multi-Agent State Machines**: Specification is broken into discrete conversational phases managed by specialized agents (Architect, Red Team, Resolution, Auditor).
2.  **The Serialized Hypergraph**: The system's "living memory." Decoupled from LLM context windows, it is serialized into a strict YAML file (`architecture.yml`) that maps files and abstraction layers as nodes and edges.
3.  **Deterministic Graph Traversal**: Light-weight Python scripts calculate the "Blast Radius" of changes, forbidding LLMs from probabilistic traversal of complex architectures.
4.  **Aggressive Lifecycle Management**: Active drafts are flushed/archived via scripts to prevent agents from ingesting outdated or conflicting context.
5.  **Candidate Artifact Protocol**: A strict boundary for testing non-deterministic or novel LLM outputs via Human-in-the-Loop verification.
6.  **Hybrid Model Orchestration**: Three-tier model routing (Opus for strategic reasoning, Sonnet for tactical tasks, Haiku for deterministic execution) with cost optimization (~50% reduction via intelligent tier selection) and per-skill override capability.
7.  **Token Enforcement & Budget Management**: Thinking token ceilings per model with per-skill overrides; output token budgets (50k default) with task-splitting guidance; separate tracking of thinking, input, and output tokens.

---

## 📁 Directory Structure

### Central Source of Truth
-   `.agents/` — **All skill, rule, schema, and script content lives here.**
    -   `skills/`: All 25 skill definitions (the source of truth for every IDE). Each skill directory uses the `hyper-` prefix (e.g. `hyper-architect/`, `hyper-redteam/`) to avoid collisions with project-specific skills in consumer repos.
    -   `schemas/`: Immutable templates for PRDs and the Hypergraph.
    -   `scripts/`: Deterministic state management tools (`hypergraph_updater.py`, `archive_specs.py`).
    -   `rules/`: Always-on coding standards (Python, security, testing, packages).
    -   `memory/`: Project context files (`activeContext`, `productContext`, `systemPatterns`).

### IDE Bridge Directories (thin, no duplicated content)
-   `.claude/commands/`: Claude Code slash commands — each is a one-line bridge to `.agents/skills/`. Commands use the `hyper-` prefix (e.g. `/hyper-architect`).
-   `.windsurf/rules/` + `.windsurf/workflows/`: Windsurf rule and workflow bridges.
-   `.cursor/rules/`: Cursor `.mdc` rule bridges.
-   `.clinerules/`: Cline rule bridges.
-   `.roo/rules/` + `.roo/rules-code/`: Roo Code rule bridges.

### Universal Standard
-   `AGENTS.md`: Cross-IDE always-on manifest (Windsurf, Cursor, Roo Code, GitHub Copilot, Zed).
-   `CLAUDE.md`: Claude Code-specific tool overrides (references `AGENTS.md`).
-   `GEMINI.md`: Gemini CLI-specific tool overrides (references `AGENTS.md`).

### Spec and Test Directories
-   `spec/`
    -   `active/`: Working drafts and Red Team reports (untrusted/temporary).
    -   `compiled/`: Ground truth (SuperPRD, MiniPRDs, `architecture.yml`).
    -   `archive/`: Historical context (blocked from agents via `.agentignore`).
-   `tests/`
    -   `candidate_outputs/`: Unverified AI outputs for manual review.
    -   `fixtures/`: Verified baselines for regression testing.
-   `docs/`: Human-readable guides (SOP, Tutorial, Whitepaper, Troubleshooting).

---

## 🛠️ Deterministic Tooling

-   **Archival Script (`archive_specs.py`)**: Ensures the `spec/active/` directory is flushed after a loop, preventing context bloat.
-   **Hypergraph Updater (`hypergraph_updater.py`)**: Performs Breadth-First Search (BFS) on the `architecture.yml` to flag dependent nodes whenever the codebase is modified.
-   **Model Router (`model_router.py`)**: Routes skills to optimal Claude model tiers (Opus/Sonnet/Haiku) based on skill metadata, with fallback logic and version compatibility checking.
-   **Heuristic Classifier (`heuristic_classifier.py`)**: YAML-based rule engine for automatic model tier suggestions during skill creation.
-   **Skill Metadata System** (`meta_loader.py`, `override_manager.py`, `ceiling_resolver.py`): Manages per-skill configurations, model assignment overrides (single_run/permanent scope), and thinking token ceiling management.
-   **Token Enforcement** (`thinking_token_monitor.py`, `ceiling_enforcer.py`, `token_budget_checker.py`): Monitors thinking token usage against per-model ceilings, enforces 50k output token budgets, and suggests task-splitting for oversized tasks.
-   **Context Compaction Engine (`compaction_engine.py`, `interrupt_detector.py`)**: Automatically compacts debate transcripts while preserving trade-off reasoning; auto-detects and recovers from interruptions.

---

## 📖 Standard Operating Procedure (SOP)

*(For full details, see the [Master SOP](docs/MasterSOP.md))*

The Hypergraph workflow is strictly sequential to prevent race conditions and graph corruption.

### Phase -1: Legacy Onboarding (Existing Projects)
1.  **Initialize**: Run `/hyper-discover` to scan code and populate `architecture.yml`.
2.  **Baseline**: Run `/hyper-baseline` to generate the first `SuperPRD.md`.

### Phase 1: The Specification Engine (Conversational)
1.  **Requirements Extraction (`/hyper-architect`)**: Exhaustive interview asking max 2 questions per turn. Generates `Draft_PRD.md`.
2.  **Adversarial Analysis (`/hyper-redteam`)**: Run in a **New Context Window**. Hunts for vulnerabilities and NFRs within the Hypergraph's Blast Radius. Generates `RedTeam_Report.md`.
3.  **Trade-off Resolution (`/hyper-resolve`)**: Run in a **New Context Window**. Present forced trade-offs (Option A vs B). Compiles final `SuperPRD.md` and `MiniPRD` files.
4.  **Memory Flush**: Run `python .agents/scripts/archive_specs.py [Feature_Name]` to clear active workspace.

### Phase 2: The Execution Engine (Building)
1.  **The Builder**: Prompt agent with a specific `MiniPRD`. Force execution of `hypergraph_updater.py` after code modification. Router automatically selects Haiku for routine tasks, Sonnet for complex reasoning.
2.  **Contract Verification (`/hyper-audit`)**: Run in a **New Context Window**. Evaluates code against MiniPRD and reconciles the `architecture.yml` hypergraph.
3.  **Context Clearing (`/hyper-clear`)**: Automatically triggered by `/hyper-audit` completion. Idempotently flushes conversation history; specs and metrics are preserved.

### Phase 3: Novel Test Protocol (Human-in-the-Loop)
1.  Outputs to `tests/candidate_outputs/`.
2.  Manual review to verify correctness.
3.  Move to `tests/fixtures/` and update MiniPRD test definition.

### Phase 4: Cost Optimization Enforcement (Post-Execution)
1.  **Token Budget Reconciliation**: Actual vs. estimated output tokens logged. Deviations >20% trigger investigation.
2.  **Model Routing Feedback**: Haiku parity validated at scale. If audit pass rate stays ≥99%, cost savings realized (~50% reduction).
3.  **Thinking Token Ceiling Review**: Monitor halt frequency. If >5% of executions halt due to thinking token overflow, escalate for per-skill override consideration.

---

## 🎯 Token Efficiency & Cost Optimization (v0.4.0)

The framework now includes a comprehensive cost optimization layer for hybrid model orchestration:

### Model Routing & Tier Selection

The framework automatically routes skills to the optimal Claude model:

- **Haiku** (2k thinking ceiling): Routine, deterministic tasks (code generation, documentation). ~70% cost reduction vs. Opus.
- **Sonnet** (10k thinking ceiling): Tactical reasoning, trade-off analysis, complex requirements. ~50% cost reduction vs. Opus.
- **Opus** (20k thinking ceiling): Strategic architectural decisions, adversarial analysis, novel problem-solving.

**How it works**: Each skill stores its assigned model in `.agents/skills/hyper-<name>/META.yml`. The router reads this metadata and invokes the skill on the assigned tier. Manual override capability with explicit scope (`--scope single_run` or `--scope permanent`) allows experimentation without foot-guns.

**Example**:
```yaml
# .agents/skills/hyper-execute/META.yml
assigned_model: haiku
model_version: "claude-haiku-4-5-20251001"
max_thinking_tokens: 2000
```

### Token Budget Enforcement

The framework enforces ceilings to prevent runaway costs:

- **Thinking Token Ceilings**: Per-model defaults (Opus 20k, Sonnet 10k, Haiku 2k) with optional per-skill overrides for legitimately complex tasks.
- **Output Token Budget**: 50k ceiling per task. If a MiniPRD estimates >50k output tokens, the framework flags it and suggests splitting into atomic subtasks.
- **Variance Tracking**: Post-execution reconciliation logs actual vs. estimated tokens. Deviations >20% trigger investigation to improve future estimates.

**Token accounting is granular**: Thinking, input, and output tokens are tracked separately. The budget ceiling (50k) applies only to output tokens; thinking and input tokens are monitored for metrics but not constrained.

### Context Compaction & Interruption Recovery

When `/hyper-resolve` completes, the debate transcript is automatically compacted into a "Final Truth" document that preserves:

- Both the Architect's and Red Team's positions
- The final resolution and rationale
- Risk mitigations
- Link to the full archived transcript

If `/hyper-resolve` is interrupted before compaction completes, `/hyper-execute` auto-detects and auto-compacts before proceeding, preventing context bloat.

### Context Clearing

The `/hyper-clear` command idempotently flushes conversation history at the end of `/hyper-audit`, preparing the session for the next feature cycle. Specs, metrics, and performance data are preserved. Calling `/hyper-clear` multiple times is safe (idempotent).

### Persistent Rules in CLAUDE.md

Static framework rules (schema definitions, confidence mandates, hypergraph specs) have been consolidated into `CLAUDE.md` to reduce per-message token overhead by ~10-15%. Migration deadline: 2026-06-17. Old schema files in `.agents/schemas/` are deprecated but remain available during the transition period.

---

## 🚀 Setup

### New Project

1.  Clone this repository and use it as your project root.
2.  **Install dependencies**:
    ```bash
    pip install pyyaml
    ```
3.  **Ensure script permissions**:
    ```bash
    chmod +x .agents/scripts/*.py
    ```

### Installing into an Existing Repo

Download and run the installer from your project root:

```bash
curl -sSL https://raw.githubusercontent.com/tjmustard/Hypergraph-Coding-Agent-Framework/main/install.sh -o install.sh && bash install.sh
```

The interactive installer will:
1. **Ask which IDE(s) to install support for** — pick from a numbered menu or type `a` for all
2. **Ask whether to add installed paths to `.gitignore`**
3. Clone the framework, copy selected files, set permissions, and install `pyyaml`

#### IDE Selection Options

```bash
# Interactive menu — choose which IDEs to install
bash install.sh

# Install specific IDEs only (comma-separated IDs)
bash install.sh --ides="claude,windsurf"

# Install all IDEs, accept all prompts automatically
bash install.sh -y

# Non-interactive (e.g. curl | bash) — installs all IDEs, skips .gitignore prompt
curl -sSL https://raw.githubusercontent.com/tjmustard/Hypergraph-Coding-Agent-Framework/main/install.sh | bash -s -- -y
```

Available IDE IDs: `claude`, `antigravity`, `windsurf`, `cursor`, `cline`, `roo`, `universal`

### Upgrading an Existing Installation

Re-running the script against a repo that already has `.agents/` installed switches automatically to **upgrade mode**, prompting you to confirm each component:

```bash
# Interactive — prompts yes/no per directory and file
bash install.sh

# Non-interactive — accepts all updates automatically
bash install.sh -y
```

**What gets installed:**

| Path | Purpose | Always / IDE-specific |
|---|---|---|
| `.agents/` | Skills (source of truth), schemas, scripts, rules, memory | Always |
| `spec/` | Active, compiled, and archive spec directories | Always |
| `tests/` | Candidate outputs and fixture directories | Always |
| `docs/` | SOP, tutorial, whitepaper, and troubleshooting guides | Always |
| `.agentignore` | Blocks agents from reading archive/candidate dirs | Always |
| `.claude/` | Claude Code slash command bridges | `claude` |
| `CLAUDE.md` | Claude Code tool overrides | `claude` |
| `GEMINI.md` | Gemini CLI tool overrides | `antigravity` |
| `.windsurf/` | Windsurf rule and workflow bridges | `windsurf` |
| `.cursor/` | Cursor `.mdc` rule bridges | `cursor` |
| `.clinerules/` | Cline rule bridges | `cline` |
| `.roo/` | Roo Code rule bridges | `roo` |
| `AGENTS.md` | Cross-IDE always-on system manifest | `universal` |

> **Note:** Bridge directories (`.claude/`, `.windsurf/`, `.cursor/`, `.clinerules/`, `.roo/`) contain only thin one-line reference files. All actual skill content lives in `.agents/skills/`.
>
> **Naming convention:** All framework skills and commands use the `hyper-` prefix (e.g. `hyper-architect`, `/hyper-redteam`) so they never collide with skills or commands you create for your own project.

### Uninstalling

To remove the framework from a project without affecting your work:

```bash
bash uninstall.sh        # interactive — confirms before removing
bash uninstall.sh -y     # non-interactive — removes without prompting
```

The uninstaller clones the framework to get the authoritative file list, then removes every file it installed. Key behaviours:

- **`spec/` and `tests/` are never touched** — your compiled specs, active drafts, candidate outputs, and fixtures are preserved.
- **Non-empty directories are kept** — if you added custom skills or files inside a framework directory (e.g. `.agents/skills/hyper-myskill/`), that directory stays.
- **Re-install at any time** — run `install.sh` again to restore the full framework.

> **Use case:** When the project you scaffolded with the framework is ready for independent development, uninstalling removes the framework's own skill files so they don't interfere with your project-specific agents — while leaving `spec/` and `tests/` intact for continued use.

---

## 🤖 AI Agent Integrations

### Architecture: No Duplication

All skill content lives **once** in `.agents/skills/*/SKILL.md`. Every IDE reads from that single source:

```
.agents/skills/hyper-architect/SKILL.md  ← source of truth
    ↑ referenced by:
    .claude/commands/hyper-architect.md      (Claude Code)
    .windsurf/workflows/hyper-architect.md   (Windsurf)
    AGENTS.md                          (Cursor, Roo Code, Copilot, Zed)
    GEMINI.md                          (Gemini CLI / Antigravity)
```

### Claude Code

Native support via `CLAUDE.md` and `.claude/commands/`. Each command is a one-line bridge to `.agents/skills/`. See **[CLAUDE.md](./CLAUDE.md)** for Claude Code-specific tool overrides.

Available slash commands: `/hyper-architect`, `/hyper-redteam`, `/hyper-resolve`, `/hyper-audit`, `/hyper-execute`, `/hyper-discover`, `/hyper-baseline`, `/hyper-clear`, `/hyper-document`, `/hyper-sop`, `/hyper-status`, `/hyper-consult-cto`, `/hyper-co-research`, `/hyper-deepdive`, and more — see `.claude/commands/` for the full list.

> **Cost Optimization**: As of v0.4.0, the framework implements hybrid model orchestration. Skills automatically route to Haiku (routine tasks, ~70% cost savings), Sonnet (tactical reasoning), or Opus (complex architectural analysis) based on metadata and heuristic rules. Thinking token ceilings and output token budgets prevent runaway costs. See the Token Efficiency feature below.

### Gemini CLI / Antigravity

Native support via `.agents/skills/` (Antigravity's native skill format) and `GEMINI.md`. See **[GEMINI.md](./GEMINI.md)** for Gemini CLI-specific tool overrides.

### Windsurf

Support via `.windsurf/rules/` (coding standards) and `.windsurf/workflows/` (slash command bridges). All files reference `.agents/` content.

### Cursor

Support via `.cursor/rules/*.mdc` with YAML frontmatter for glob-based activation. The `hypergraph-agent.mdc` rule is always-on and directs Cursor to read `AGENTS.md` and skill files by name.

### Cline

Support via `.clinerules/` directory with rule bridges to `.agents/rules/`.

### Roo Code

Support via `.roo/rules/` (all modes) and `.roo/rules-code/` (code mode only), with rule bridges to `.agents/rules/`.

### GitHub Copilot / Zed / Others

Support via `AGENTS.md` at the repository root, which is the universal always-on standard read by Copilot Workspace, Zed, and any IDE supporting the `AGENTS.md` protocol.

---

## ❓ Troubleshooting Overview

*(For an in-depth guide, see [Troubleshooting.md](docs/Troubleshooting.md))*

-   **Hallucinations**: Usually caused by forgotten archives. Run `archive_specs.py`.
-   **Desynchronization**: Builder missed `hypergraph_updater.py`. Run it manually.
-   **Scope Creep**: Red Team suggesting features. Re-run `/hyper-redteam` with strict override.
-   **Corruption**: Malformed YAML. Restore `architecture.yml` from Git.
-   **Infinite Loop**: Vague answers to Architect. Provide quantified technical details.
-   **Thinking Token Ceiling Halt**: Task complexity exceeds model's ceiling. Either (A) split into smaller subtasks, or (B) set per-skill override in META.yml: `max_thinking_tokens: 15000` (for Sonnet). Document complexity indicators (ambiguity, novel patterns, edge cases) in the override reason.
-   **Output Token Budget Exceeded**: Estimated output >50k tokens. Split MiniPRD into atomic subtasks (e.g., core logic, API endpoints, tests). Or override with `--force-proceed --reason "Large module necessary"` if justified.
-   **High Cost Unexpectedly**: Check that skills are routing to correct model tier. Run `python .agents/scripts/model_router.py <skill_name>` to verify assignment. Use `/hyper-config set-model [skill] [model] --scope permanent` to adjust permanently.

---

## Roadmap

- [ ] Agent Compatibility
  - [x] Claude Code
  - [x] Gemini CLI / Antigravity
  - [x] Windsurf
  - [x] Cursor
  - [x] Cline
  - [x] Roo Code
  - [x] GitHub Copilot (via AGENTS.md)
  - [x] Zed (via AGENTS.md)
  - [ ] Aider
  - [ ] Continue.dev
