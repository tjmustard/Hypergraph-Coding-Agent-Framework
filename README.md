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

-   `docs/`
    -   [`MasterSOP.md`](docs/MasterSOP.md): Comprehensive Standard Operating Procedure.
    -   [`Troubleshooting.md`](docs/Troubleshooting.md): Solutions to common issues.
    -   [`Tutorial.md`](docs/Tutorial.md): Step-by-step framework guide.
    -   [`Whitepaper.md`](docs/Whitepaper.md): Foundational theory and architecture.
-   `.agents/`
    -   `skills/`: Custom slash commands (`/architect`, `/redteam`, etc.).
    -   `schemas/`: Immutable templates for PRDs and the Hypergraph.
    -   `scripts/`: Deterministic state management tools (`hypergraph_updater.py`, `archive_specs.py`).
    -   `workflows/`: Automated agent workflows (e.g., Antigravity integration).
-   `spec/`
    -   `active/`: Working drafts and Red Team reports (untrusted/temporary).
    -   `compiled/`: Ground truth (SuperPRD, MiniPRDs, `architecture.yml`).
    -   `archive/`: Historical context (blocked from agents via `.agentignore`).
-   `tests/`
    -   `candidate_outputs/`: Unverified AI outputs for manual review.
    -   `fixtures/`: Verified baselines for regression testing.

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

1.  **Clone individual templates** or this repository.
2.  **Install dependencies**:
    ```bash
    pip install pyyaml
    ```
3.  **Ensure script permissions**:
    ```bash
    chmod +x .agents/scripts/*.py
    ```

---

## 🤖 Gemini CLI Integration

This framework provides native support for fully automated, multi-agent workflows using [Gemini CLI](https://github.com/google/gemini-cli). Check out the **[Gemini Integration Guide (GEMINI.md)](./GEMINI.md)** to see how `gemini-cli` orchestrates the scripts and agents autonomously.

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
  - [ ] Claude Code
  - [ ] Cursor
  - [ ] Antigravity