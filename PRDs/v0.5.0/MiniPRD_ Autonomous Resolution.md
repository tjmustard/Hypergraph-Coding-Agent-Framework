# **MiniPRD: Autonomous Resolution Nodes**

## **Target**

.agents/scripts/hyper\_fix.py and .agents/scripts/hyper\_resolve\_conflict.py

## **Context**

To achieve full autonomy, the daemon needs dedicated nodes to handle test failures and git merge conflicts.

## **Constraints**

* **Context Management:** hyper\_fix.py must ingest the SuperPRD, MiniPRD, and error trace to prevent hallucinated fixes.  
* **Safety Threshold:** hyper\_resolve\_conflict.py MUST force a JSON response schema and explicitly check confidence\_score \>= 85\.

## **Acceptance Criteria**

* \[ \] hyper\_fix.py correctly parses error logs and issues code patches via the LLM router.  
* \[ \] hyper\_resolve\_conflict.py successfully parses conflicted files with standard Git markers (\<\<\<\<\<\<\<).  
* \[ \] Conflicts scoring \<85 are aborted, and the file is left unmodified for human intervention.  
* \[ \] Conflicts scoring \>=85 have markers removed and corrected logic written to disk.

## **Implementation Steps**

1. Create hyper\_fix.py. Build a prompt triangulating global intent (SuperPRD), local intent (MiniPRD), and failure state.  
2. Create hyper\_resolve\_conflict.py. Define the strict JSON schema (confidence\_score, reasoning, resolved\_code).  
3. Wire both scripts to the existing model\_router.py API logic.