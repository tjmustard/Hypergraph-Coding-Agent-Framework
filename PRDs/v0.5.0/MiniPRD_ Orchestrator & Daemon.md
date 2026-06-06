# **MiniPRD: Orchestrator & Daemon Loop**

## **Target**

hyper\_orchestrator.py and hyper\_daemon.py

## **Context**

We require a headless process manager to handle Git branching and a daemon to handle the autonomous code generation and testing loop.

## **Constraints**

* Must use subprocess for all Git and OS-level operations.  
* Must execute tests using uv run to ensure dependency isolation and speed.  
* Daemon loop must cap at 5 max iterations to prevent infinite token burns.

## **Acceptance Criteria**

* \[ \] hyper\_orchestrator.py successfully reads a directory of PRDs, creates branches like feature/prd-name, and spawns asynchronous daemon processes.  
* \[ \] hyper\_orchestrator.py synchronously rebases successful branches back to main.  
* \[ \] hyper\_daemon.py successfully triggers execution, audit, and test commands sequentially.  
* \[ \] On test failure, hyper\_daemon.py correctly saves the error trace and routes it to hyper\_fix.py.

## **Implementation Steps**

1. Create hyper\_orchestrator.py with ThreadPoolExecutor for parallel branch fanning and a synchronous sequential loop for the git rebase pipeline.  
2. Create hyper\_daemon.py with subprocess.run wrapping standard framework commands.  
3. Inject the HYPERGRAPH\_PROVENANCE environment variable in the daemon before calling sub-agents.