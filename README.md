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

---

## 📁 Directory Structure

### Central Source of Truth
-   `.agents/` — **All skill, rule, schema, and script content lives here.**
    -   `skills/`: All 25 skill definitions (the source of truth for every IDE).
    -   `schemas/`: Immutable templates for PRDs and the Hypergraph.
    -   `scripts/`: Deterministic state management tools (`hypergraph_updater.py`, `archive_specs.py`).
    -   `rules/`: Always-on coding standards (Python, security, testing, packages).
    -   `memory/`: Project context files (`activeContext`, `productContext`, `systemPatterns`).

### IDE Bridge Directories (thin, no duplicated content)
-   `.claude/commands/`: Claude Code slash commands — each is a one-line bridge to `.agents/skills/`.
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

---

## 📖 Standard Operating Procedure (SOP)

*(For full details, see the [Master SOP](docs/MasterSOP.md))*

The Hypergraph workflow is strictly sequential to prevent race conditions and graph corruption.

### Phase -1: Legacy Onboarding (Existing Projects)
1.  **Initialize**: Run `/discover` to scan code and populate `architecture.yml`.
2.  **Baseline**: Run `/baseline` to generate the first `SuperPRD.md`.

### Phase 1: The Specification Engine (Conversational)
1.  **Requirements Extraction (`/architect`)**: Exhaustive interview asking max 2 questions per turn. Generates `Draft_PRD.md`.
2.  **Adversarial Analysis (`/redteam`)**: Run in a **New Context Window**. Hunts for vulnerabilities and NFRs within the Hypergraph's Blast Radius. Generates `RedTeam_Report.md`.
3.  **Trade-off Resolution (`/resolve`)**: Run in a **New Context Window**. Present forced trade-offs (Option A vs B). Compiles final `SuperPRD.md` and `MiniPRD` files.
4.  **Memory Flush**: Run `python .agents/scripts/archive_specs.py [Feature_Name]` to clear active workspace.

### Phase 2: The Execution Engine (Building)
1.  **The Builder**: Prompt agent with a specific `MiniPRD`. Force execution of `hypergraph_updater.py` after code modification.
2.  **Contract Verification (`/audit`)**: Run in a **New Context Window**. Evaluates code against MiniPRD and reconciles the `architecture.yml` hypergraph.

### Phase 3: Novel Test Protocol (Human-in-the-Loop)
1.  Outputs to `tests/candidate_outputs/`.
2.  Manual review to verify correctness.
3.  Move to `tests/fixtures/` and update MiniPRD test definition.

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

From your project root, run:

```bash
curl -sSL https://raw.githubusercontent.com/tjmustard/Hypergraph-Coding-Agent-Framework/main/install.sh | bash
```

The script will:
- Clone the framework into a temporary directory
- Copy all IDE bridge directories and central `.agents/` content into your project
- Copy root config files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.agentignore`)
- Set script permissions and install the `pyyaml` dependency

### Upgrading an Existing Installation

Re-running the script against a repo that already has the framework installed switches automatically to **upgrade mode**, prompting you to confirm each component:

```bash
# Interactive — prompts yes/no per directory and file
bash install.sh

# Non-interactive — accepts all updates automatically
bash install.sh -y
```

> **Note:** `curl | bash` is non-interactive by default. Download the script first if you want the upgrade prompts:
> ```bash
> curl -sSL https://raw.githubusercontent.com/tjmustard/Hypergraph-Coding-Agent-Framework/main/install.sh -o install.sh
> bash install.sh
> ```

**What gets installed:**

| Path | Purpose |
|---|---|
| `.agents/` | Skills (source of truth), schemas, scripts, rules, memory |
| `.claude/` | Claude Code slash command bridges |
| `.windsurf/` | Windsurf rule and workflow bridges |
| `.cursor/` | Cursor `.mdc` rule bridges |
| `.clinerules/` | Cline rule bridges |
| `.roo/` | Roo Code rule bridges |
| `spec/` | Active, compiled, and archive spec directories |
| `tests/` | Candidate outputs and fixture directories |
| `docs/` | SOP, tutorial, whitepaper, and troubleshooting guides |
| `AGENTS.md` | Cross-IDE always-on system manifest |
| `CLAUDE.md` | Claude Code tool overrides |
| `GEMINI.md` | Gemini CLI tool overrides |
| `.agentignore` | Blocks agents from reading archive/candidate dirs |

> **Note:** Bridge directories (`.claude/`, `.windsurf/`, `.cursor/`, `.clinerules/`, `.roo/`) contain only thin one-line reference files. All actual skill content lives in `.agents/skills/`.

---

## 🤖 AI Agent Integrations

### Architecture: No Duplication

All skill content lives **once** in `.agents/skills/*/SKILL.md`. Every IDE reads from that single source:

```
.agents/skills/architect/SKILL.md  ← source of truth
    ↑ referenced by:
    .claude/commands/architect.md      (Claude Code)
    .windsurf/workflows/architect.md   (Windsurf)
    AGENTS.md                          (Cursor, Roo Code, Copilot, Zed)
    GEMINI.md                          (Gemini CLI / Antigravity)
```

### Claude Code

Native support via `CLAUDE.md` and `.claude/commands/`. Each command is a one-line bridge to `.agents/skills/`. See **[CLAUDE.md](./CLAUDE.md)** for Claude Code-specific tool overrides.

Available slash commands: `/architect`, `/redteam`, `/resolve`, `/audit`, `/execute`, `/discover`, `/baseline`, `/sop`, `/status`, `/consult-cto`, `/co-research`, `/deepdive`, and more — see `.claude/commands/` for the full list.

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
-   **Scope Creep**: Red Team suggesting features. Re-run `/redteam` with strict override.
-   **Corruption**: Malformed YAML. Restore `architecture.yml` from Git.
-   **Infinite Loop**: Vague answers to Architect. Provide quantified technical details.

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
