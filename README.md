# Coding 4.0: Agentic Specification Template

A rigorously structured framework designed to solve the **Specification Alignment Problem** in AI-assisted coding.

## Directory Structure

  - `.agent/skills/`: Custom slash commands (`/architect`, `/redteam`, etc.).
  - `.agent/schemas/`: Immutable templates for PRDs and the Hypergraph.
  - `.agent/scripts/`: Deterministic state management tools.
  - `spec/active/`: Working drafts (untrusted).
  - `spec/compiled/`: Ground truth (SuperPRD, MiniPRDs, architecture.yml).
  - `spec/archive/`: Historical context (blocked from agents via `.agentignore`).

## The Workflow

1.  **Define**: Use `/architect` for the interview.
2.  **Attack**: Use `/redteam` to find vulnerabilities.
3.  **Resolve**: Use `/resolve` to finalize specs and archive drafts.
4.  **Build**: Prompt your agent to implement a `MiniPRD`.
5.  **Audit**: Use `/audit` to verify code and reconcile the Hypergraph.

## Setup

```bash
pip install pyyaml
chmod +x .agent/scripts/*.py
```