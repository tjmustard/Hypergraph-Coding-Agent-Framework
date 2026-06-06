# 🛠️ Hypergraph Skill Index & Developer Guide

*Comprehensive catalog of available AI agent capabilities and the open standard for extending them.*

---

## 📂 Available Skills Index

The Hypergraph framework leverages a modular skill system to route specialized reasoning tiers. Below is the authoritative index of all available skills, organized by workflow phase.

### Phase -1: Legacy Onboarding (Brownfield Projects)
| Skill Name | Slash Trigger | Description |
| :--- | :--- | :--- |
| **`hyper-discover`** | `/hyper-discover` | Scans the existing codebase to initialize or update the `architecture.yml` hypergraph. |
| **`hyper-baseline`** | `/hyper-baseline` | Reverse-engineers the existing codebase to generate a "Current State" SuperPRD. |

### Phase 0: Scaffolding
| Skill Name | Slash Trigger | Description |
| :--- | :--- | :--- |
| **`hyper-init`** | `/hyper-init` | Scaffolds standard repository documentation templates (`README.md`, `CONTRIBUTING.md`, etc.) via an interactive user interview. |

### Phase 1: Specification Engine (Conversational)
| Skill Name | Slash Trigger | Description |
| :--- | :--- | :--- |
| **`hyper-architect`** | `/hyper-architect` | Conducts a state-machine interview to extract requirements and compile the initial `Draft_PRD.md`. |
| **`hyper-redteam`** | `/hyper-redteam` | Runs adversarial analysis on the Draft PRD to identify edge cases, vulnerabilities, and system-level blast radius risks. |
| **`hyper-resolve`** | `/hyper-resolve` | Mediates Red Team findings, forces architectural trade-offs, and compiles the final `SuperPRD` + modular `MiniPRD` specifications. |

### Phase 2: Build & Verification Engine
| Skill Name | Slash Trigger | Description |
| :--- | :--- | :--- |
| **`hyper-execute`** | `/hyper-execute` | Implements changes precisely against a compiled MiniPRD, updates hypergraph status, and triggers updater scripts. |
| **`hyper-audit`** | `/hyper-audit` | Strictly verifies implementation correctness against its MiniPRD and reconciles the hypergraph state. |
| **`hyper-clear`** | `/hyper-clear` | Idempotently flushes conversation context between build cycles while preserving specifications and metrics. |
| **`hyper-contextualize`** | `/hyper-contextualize` | Audits `CLAUDE.md`, `AGENTS.md`, and `GEMINI.md` in installed projects to ensure HACF is framed as a development toolchain rather than the project subject. Offers Replace-with-template, Inject-banner, or Per-file-diff fix modes, and reports HACF bleed found in `README.md`. |

### Phase Any: Developer Productivity & Utilities
| Skill Name | Slash Trigger | Description |
| :--- | :--- | :--- |
| **`hyper-status`** | `/hyper-status` | Outputs the current, live-updated "Living Master Plan" snapshot including project status, constraints, and task progress. |
| **`hyper-sop`** | `/hyper-sop` | Re-anchors the agent and user to the correct framework phase and Master SOP guidelines. |
| **`hyper-consult-cto`** | `/hyper-consult-cto` | Activates a CTO persona for brainstorming architecture, trade-offs, and early feature planning. |
| **`hyper-co-research`** | `/hyper-co-research` | Instantiates a peer-level research partner applying First Principles thinking and strict epistemic humility. |
| **`hyper-deepdive`** | `/hyper-deepdive` | Pauses building to explore a technical topic deeply from first principles before making structural decisions. |
| **`hyper-create-skill`** | `/hyper-create-skill` | Converts an agent prompt or custom instruction set into a new structured skill for the framework. |
| **`hyper-new-workflow`** | `/hyper-new-workflow` | Generates a new slash command workflow with accompanying IDE rule bridges. |
| **`hyper-document`** | `/hyper-document` | Updates README, CHANGELOG, docs/, AGENTS.md, memory, and templates after code or skill changes. |
| **`hyper-grill-docs`** | `/hyper-grill-docs` | Domain-sharpening interview that maintains `CONTEXT.md` (canonical glossary) and `docs/adr/` (Architecture Decision Records) inline as decisions crystallise. Challenges vague terminology, cross-references code against stated behavior, stress-tests domain boundaries with concrete scenarios, and gates ADR creation on hard-to-reverse + surprising + real-trade-off decisions. |
| **`hyper-handoff`** | `/hyper-handoff` | Compacts the current conversation into a handoff document saved to the OS temp directory. References existing artifacts (PRDs, commits, specs) by path rather than reproducing them. Includes a "Suggested Skills" section for the next session. Pass an optional argument describing what the next session will focus on. |
| **`hyper-session-update`** | `/hyper-session-update` | Syncs agent memory files (`activeContext.md`, `systemPatterns.md`, etc.) with the work done in the current session. |
| **`hyper-update`** | `/hyper-update` | Smart-upgrade CLI to safely fetch upstream framework updates while preserving local rules customizations. |
| **`hyper-refresh-memory`** | `/hyper-refresh-memory` | Rebuilds the agent's mental model and synchronization state by reading memory, rules, and source files. |
| **`hyper-troubleshooting`** | `/hyper-troubleshooting` | Guides users through recovering from framework errors, hallucinations, or desynchronized state. |
| **`hyper-tutorial`** | `/hyper-tutorial` | Runs an interactive step-by-step tutorial walkthrough (Email Newsletter Subscription scenario). |
| **`hyper-tutorial-generator`** | `/hyper-tutorial-generator` | Collaboratively generates markdown tutorials from integration tests or provided source files. |
| **`hyper-stitch-design`** | `/hyper-stitch-design` | Translates UX ideas and visual mockups into a concrete Design System specification with design tokens. |
| **`hyper-prompt-engineer`** | `/hyper-prompt-engineer` | Designs and optimizes prompts using advanced LLM structuring and meta-prompting techniques. |
| **`hyper-template-architect`** | `/hyper-template-architect` | Reverse-engineers a completed document into a reusable template for downstream AI pipelines. |
| **`hyper-peer-review`** | `/hyper-peer-review` | Triages and evaluates external model code reviews against the actual codebase to produce an action plan. |
| **`hyper-create-issue`** | `/hyper-create-issue` | Captures bugs or feature ideas into a structured GitHub issue format without breaking development flow. |
| **`hyper-publish`** | `/hyper-publish` | Automated commit-push-PR routine using AI-proposed summaries and interactive HITL gates. |
| **`hyper-learning-opportunity`** | `/hyper-learning-opportunity` | Pauses development to teach a technical concept at multiple layers of complexity (tailored to PMs). |

---

## 🛠️ The Skill Standard (For Developers)

Skills are an open standard for extending agent capabilities. A skill is a folder containing a `SKILL.md` file with instructions that the agent can discover, activate, and follow when working on specific tasks.

### Where Skills Live
Antigravity supports two scopes of skills:

| Scope | Location | Use Case |
| :--- | :--- | :--- |
| **Workspace-Specific** | `<workspace-root>/.agents/skills/<skill-folder>/` | Team deployment workflows, local testing conventions, project-specific code generators. |
| **Global** | `~/.gemini/antigravity/skills/<skill-folder>/` | Universal developer utilities, personal code formatters, general research prompts. |

### Creating a Skill

To create a new skill, create a folder in one of the directories above with a `SKILL.md` file:

```
.agents/skills/
└─── my-custom-skill/
    └─── SKILL.md
```

### Frontmatter Schema

Every skill needs a `SKILL.md` file containing YAML frontmatter at the very top:

```markdown
---
name: my-custom-skill
description: Reviews code changes for style, performance, and best practices. Use when evaluating PRs or running QA.
---

# Code Review Skill

When reviewing code, follow these steps...
```

#### Fields Reference:
- **`name`** *(Optional)*: A unique identifier for the skill (lowercase, hyphens for spaces). Defaults to the folder name.
- **`description`** *(Required)*: A clear, concise third-person description of what the skill does and when to use it. This is what the agent reads when scanning available capabilities to match the user's intent.

> [!TIP]
> Always include relevant keywords in the description (e.g. "Python, pytest, CI/CD") to help the agent recognize when the skill is appropriate.

### Skill Folder Structure

While `SKILL.md` is the only required file, you can organize a skill with supporting assets:

```
.agents/skills/my-custom-skill/
├─── SKILL.md       # Main agent instructions (required)
├─── META.yml       # Skill metadata, model routing & budgets (optional)
├─── scripts/       # Helper scripts and automation tools (optional)
├─── examples/      # Reference templates and code fixtures (optional)
└─── resources/     # Additional system assets and guidelines (optional)
```

### How the Agent Uses Skills

Skills are parsed using a **Progressive Disclosure** pattern to optimize context windows:

1. **Discovery**: When a session starts, the agent scans all skill directories and reads ONLY the names and descriptions from the frontmatter.
2. **Activation**: If a skill matched the user's query or trigger (e.g., the user types `/hyper-architect`), the agent reads the full `SKILL.md` content.
3. **Execution**: The agent strictly follows the instructions and constraints defined in the skill file to execute the task.