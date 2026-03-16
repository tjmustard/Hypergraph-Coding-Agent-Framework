# **Master SOP: Hypergraph Coding Agent Framework Workflow**

**Version:** 1.0 (Strict Sequential Execution Model)

**Core Paradigm:** Spec-First, Deterministic Memory, Automated Auditing

This standard operating procedure dictates the exact sequence of operations for generating, executing, and auditing software utilizing the Hypergraph Coding Agent Framework architecture. Do not deviate from the sequence. Bypassing the specification or auditing phases will result in context collapse, hallucinated requirements, and system graph corruption.

## **Phase \-1: Legacy Onboarding (Brownfield Projects Only)**

If you are implementing this framework in an existing repository, you must map the territory before starting Phase 1\.

1. **Initialize the Hypergraph:** Execute /hyper-discover. The agent will scan your code and populate spec/compiled/architecture.yml.  
2. **Review the Map:** Open the YAML file. Verify that the major modules and dependencies were captured correctly.  
3. **Baseline the System:** Execute /hyper-baseline. The agent will generate the first SuperPRD.md.  
4. **Verification:** Read the SuperPRD.md. If it accurately reflects what your software does today, you are ready to proceed to **Phase 1: Step 1 (/hyper-architect)** to add your first new feature.

## **Phase 0: System Initialization**

### **Greenfield Project Setup**

1. **Clone the Template:** Clone this repository into your target directory. It contains the required `.agents/` tooling and empty `.gitkeep` directories.
2. **Environment Validation:** Ensure Python 3 is installed. Install the PyYAML dependency required for graph traversal:
   ```bash
   pip install pyyaml
   ```
3. **Execution Permissions:** Ensure the deterministic scripts are executable:
   ```bash
   chmod +x .agents/scripts/hypergraph_updater.py
   chmod +x .agents/scripts/archive_specs.py
   ```

## **Phase 1: The Specification Engine**

This phase is entirely conversational. It is designed to extract constraints, map the blast radius of changes, and force architectural trade-offs *before* a single line of code is written.

### **Step 1: Requirements Extraction (/hyper-architect)**

1. Open your agentic IDE (Antigravity/Cursor/Claude Code).  
2. Execute the /hyper-architect command.  
3. **The Pacing Loop:** The agent will ask a maximum of 2 questions per turn. Answer them thoroughly. Do not attempt to skip phases.  
4. **Artifact:** The agent will generate Draft\_PRD.md in the spec/active/ directory.

### **Step 2: Adversarial Analysis (/hyper-redteam)**

1. **CRITICAL:** Open a **New Context Window** (or clear the agent session). Do not let the Red Team agent read the Architect's conversation history.  
2. Execute the /hyper-redteam command.  
3. The agent will read Draft\_PRD.md (and architecture.yml if this is an iterative update) to hunt for vulnerabilities, data contract collisions, and missing Non-Functional Requirements (NFRs).  
4. **Artifact:** The agent will generate RedTeam\_Report.md in spec/active/.

### **Step 3: Trade-off Resolution (/hyper-resolve)**

1. Open a **New Context Window**.  
2. Execute the /hyper-resolve command.  
3. The agent will read the Draft PRD and Red Team Report. It will present you with forced trade-offs (Option A vs. Option B) for every vulnerability found.  
4. **Artifact Generation:** Upon completion, the agent will compile the final SuperPRD.md and the granular MiniPRD\_\[Module\].md files, saving them to spec/compiled/.  
5. **Memory Flush:** The agent will instruct you to execute the archival script. Run it to clear the active workspace:
   ```bash
   python .agents/scripts/archive_specs.py [Feature_Name]
   ```

## **Phase 2: The Execution Engine (The Build Loop)**

This phase maps to the actual writing of syntax. It is governed by a strict state-machine boundary and deterministic graph traversal.

### **Step 1: The Builder (/hyper-execute)**

1. Open a **New Context Window**.
2. Execute: `/hyper-execute spec/compiled/MiniPRD_[Target].md`
   The skill reads the MiniPRD, implements the code precisely, and automatically runs `hypergraph_updater.py` before halting.
3. **Wait for the skill to fully complete** before proceeding to Step 2. Do NOT run `/hyper-audit` in the same context window.

### **Step 2: Contract Verification (/hyper-audit)**

1. **CRITICAL:** Ensure `/hyper-execute` has completely finished. *Parallel execution will corrupt the YAML graph.*
2. Open a **New Context Window**.
3. Execute: `/hyper-audit spec/compiled/MiniPRD_[Target].md`
4. The Auditor evaluates the code against the strict MiniPRD constraints.
5. **Reconciliation:** If the code passes, the Auditor rewrites the `needs_review` nodes in `architecture.yml` to match the new inputs/outputs, resets their status to `clean`, and moves the MiniPRD to `spec/archive/` to prevent it from surfacing in future `/hyper-execute` runs.

## **Phase 3: Novel Test Protocol (Human-in-the-Loop)**

Standard CI/CD cannot test subjective or AI-generated outputs. If a MiniPRD contains a Novel Test:

1. The Builder/Auditor will output the result to tests/candidate\_outputs/ and halt execution.  
2. Review the file manually.  
3. If the output is correct, move the file to tests/fixtures/.  
4. Manually update the MiniPRD test definition from novel to deterministic. The system will now automatically run regressions against this approved baseline.

## **Phase 4: Iterative Updates (The Delta Loop)**

When adding new features weeks or months later, the process remains identical.

1. Run `/hyper-architect`. The agent detects the existing `architecture.yml` and switches to the **Delta Extraction** protocol.
2. Run `/hyper-redteam`. It extracts the **Blast Radius** subgraph to identify exactly how the new feature collides with existing code.
3. Run `/hyper-resolve` to finalize MiniPRDs and archive active drafts.
4. Run `/hyper-execute spec/compiled/MiniPRD_[Target].md` to implement.
5. Run `/hyper-audit spec/compiled/MiniPRD_[Target].md` to verify and reconcile.
