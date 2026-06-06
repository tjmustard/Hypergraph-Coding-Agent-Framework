# **SuperPRD: Dynamic Workflow & Parallel Execution Engine**

## **1\. Intent & Context**

The Hypergraph Coding Agent Framework currently operates on a strictly sequential state machine (/hyper-execute \-\> /hyper-audit). This creates a wall-clock bottleneck for complex features.

This project transitions the framework to a parallel, dynamic workflow model inspired by Claude Code. It introduces isolated Git branch sandboxing, headless autonomous testing loops (the "Oracle"), and AI-driven Git conflict resolution, while preserving the deterministic properties of the architecture.yml hypergraph.

## **2\. Architecture & Blast Radius**

**Target Subsystems:**

* .agents/scripts/: Introduction of new daemon, orchestrator, and autonomous fix/resolve scripts.  
* spec/compiled/architecture.yml: Schema update to support \_provenance metadata.  
* Execution Protocol: Moving from IDE slash commands to headless uv run subprocesses.

**Core Components to Implement:**

1. hyper\_orchestrator.py: The parent process manager. Fans out SuperPRDs into isolated Git branches.  
2. hyper\_daemon.py: The headless execution loop (Execute \-\> Audit \-\> uv run pytest \-\> Fix).  
3. hyper\_fix.py: A dedicated debugging node triangulating intent and stack traces.  
4. hyper\_resolve\_conflict.py: An AI node utilizing confidence-gated schemas to merge text conflicts.  
5. hypergraph\_updater.py (Patch): Must read HYPERGRAPH\_PROVENANCE to tag graph nodes.

## **3\. Strict Constraints**

1. **No Single-Branch Parallelization:** Execution agents MUST NOT run concurrently on the same branch. I/O race conditions will corrupt the test suite and YAML graph.  
2. **Oracle Determinism:** The daemon must rely on uv run pytest (or equivalent) for exit code 0\. LLM self-evaluation is strictly prohibited for the test phase.  
3. **Epistemic Gating:** hyper\_resolve\_conflict.py must abort operations if its self-evaluated confidence score falls below 85/100.

## **4\. Sub-Tasks (MiniPRDs Required)**

* \[ \] MiniPRD\_Dynamic\_Orchestrator: Implement branch fanning and the daemon loop.  
* \[ \] MiniPRD\_Autonomous\_Resolution: Implement the Fix agent and Git Conflict Resolver.  
* \[ \] MiniPRD\_Provenance\_Integration: Patch the existing YAML updater for metadata tracking.