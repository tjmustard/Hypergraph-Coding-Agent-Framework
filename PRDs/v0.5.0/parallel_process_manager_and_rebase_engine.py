import subprocess
import os
import sys
from concurrent.futures import ThreadPoolExecutor

def get_active_branch():
    result = subprocess.run(["git", "branch", "--show-current"], capture_output=True, text=True)
    return result.stdout.strip()

def get_conflicted_files():
    """Returns a list of files currently in a conflicted state during a rebase."""
    result = subprocess.run(["git", "diff", "--name-only", "--diff-filter=U"], capture_output=True, text=True)
    return [f for f in result.stdout.split('\n') if f]

def handle_rebase_conflicts():
    """Routes conflicts to appropriate resolution engines."""
    conflicted_files = get_conflicted_files()
    if not conflicted_files:
        return True
        
    for file in conflicted_files:
        print(f"  [*] Handling conflict in: {file}")
        
        if file.endswith("architecture.yml"):
            # Route to deterministic semantic merger
            # Note: Git inserts markers, making standard YAML parsing fail. 
            # In a prod environment, we would extract the base, local, and remote 
            # objects via git blob and pass them to hypergraph_merger.py.
            print("  [!] architecture.yml conflict detected. Human intervention recommended for this prototype phase.")
            return False
        else:
            # Route to AI Conflict Resolver
            resolve_cmd = ["python", ".agents/scripts/hyper_resolve_conflict.py", file]
            result = subprocess.run(resolve_cmd)
            
            if result.returncode != 0:
                print(f"  [-] AI Resolver aborted on {file} (Low Confidence/Error).")
                return False
                
        # If successfully resolved by AI/Script, stage the file
        subprocess.run(["git", "add", file], check=True)
        
    # Continue the rebase
    print("  [*] All conflicts tentatively resolved. Continuing rebase...")
    rebase_cont = subprocess.run(["git", "rebase", "--continue"], capture_output=True, text=True)
    return rebase_cont.returncode == 0

def execute_rebase_pipeline(branch_name):
    """Attempts to merge a successful branch back into main."""
    print(f"\n[>>>] Initiating Rebase Protocol for {branch_name}")
    
    subprocess.run(["git", "checkout", "main"], capture_output=True)
    subprocess.run(["git", "pull", "origin", "main"], capture_output=True)
    subprocess.run(["git", "checkout", branch_name], capture_output=True)
    
    print(f"[*] Rebasing {branch_name} onto main...")
    rebase = subprocess.run(["git", "rebase", "main"], capture_output=True, text=True)
    
    if rebase.returncode != 0:
        print("[!] Rebase conflict detected.")
        success = handle_rebase_conflicts()
        if not success:
            print(f"[-] Automated rebase failed for {branch_name}. Aborting rebase.")
            subprocess.run(["git", "rebase", "--abort"])
            subprocess.run(["git", "checkout", "main"])
            return False
            
    print("[*] Rebase successful. Running Global Oracle Test Suite...")
    oracle = subprocess.run(["uv", "run", "pytest", "--maxfail=1"], capture_output=True, text=True)
    
    if oracle.returncode == 0:
        print(f"[+] Global tests passed! Merging {branch_name} into main.")
        subprocess.run(["git", "checkout", "main"], check=True)
        subprocess.run(["git", "merge", branch_name], check=True)
        return True
    else:
        print(f"[-] Global tests FAILED after rebase for {branch_name}. Regression detected.")
        print("[-] You must manually route this branch back to the Fix Agent.")
        subprocess.run(["git", "checkout", "main"])
        return False

def process_superprd(superprd_file):
    """Isolates a SuperPRD, runs daemon, and tracks success."""
    superprd_name = os.path.basename(superprd_file).replace(".md", "")
    branch_name = f"feature/{superprd_name.lower().replace(' ', '-')}"
    
    print(f"\n[>>>] Spawning workflow for: {superprd_name} on branch {branch_name}")
    
    try:
        subprocess.run(["git", "checkout", "-b", branch_name], check=True, capture_output=True)
        miniprd_target = f"spec/compiled/MiniPRD_{superprd_name}.md"
        
        # Fire the daemon in this branch
        daemon_cmd = ["python", "hyper_daemon.py", superprd_name, miniprd_target]
        result = subprocess.run(daemon_cmd)
        
        if result.returncode == 0:
            print(f"[<<<] Workflow complete for {superprd_name}.")
            return branch_name
        else:
            print(f"[!] Workflow failed for {superprd_name}.")
            return None
    except Exception as e:
        print(f"[!] Error on {superprd_name}: {e}")
        return None
    finally:
        subprocess.run(["git", "checkout", "main"], capture_output=True)

def orchestrate_parallel_workflows(superprd_directory):
    """Main execution block."""
    if not os.path.exists(superprd_directory):
        print(f"Directory {superprd_directory} not found.")
        sys.exit(1)
        
    superprds = [os.path.join(superprd_directory, f) for f in os.listdir(superprd_directory) if f.endswith('.md')]
    
    # 1. Parallel Execution Phase
    with ThreadPoolExecutor(max_workers=len(superprds)) as executor:
        completed_branches = list(executor.map(process_superprd, superprds))
        
    successful_branches = [b for b in completed_branches if b is not None]
    
    # 2. Sequential Rebase Pipeline Phase
    # Rebasing must be done synchronously to prevent race conditions on main
    print(f"\n[*] Commencing Sequential Rebase Pipeline for {len(successful_branches)} branches...")
    for branch in successful_branches:
        execute_rebase_pipeline(branch)
        
    print("\n[+] Orchestration Complete.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python hyper_orchestrator.py <path_to_superprds>")
        sys.exit(1)
        
    if get_active_branch() != "main":
        print("[!] Orchestrator must be run from the 'main' branch.")
        sys.exit(1)
        
    orchestrate_parallel_workflows(sys.argv[1])
