import subprocess
import os
import sys

def run_agent_script(script_name, args, env_vars=None):
    """
    Executes an existing framework script (e.g., hyper-execute).
    """
    env = os.environ.copy()
    if env_vars:
        env.update(env_vars)
        
    cmd = ["python", f".agents/scripts/{script_name}.py"] + args
    print(f"    [LLM] Executing: {' '.join(cmd)}")
    
    result = subprocess.run(cmd, env=env, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"    [!] Agent Error: {result.stderr}")
    return result.returncode == 0

def run_oracle_tests():
    """
    The Deterministic Oracle. Runs Ruff (linting) then Pytest (logic).
    """
    print("    [ORACLE] Running 'uv run ruff check .'...")
    ruff = subprocess.run(["uv", "run", "ruff", "check", "."], capture_output=True, text=True)
    if ruff.returncode != 0:
        return ruff.returncode, ruff.stdout, ruff.stderr

    print("    [ORACLE] Running 'uv run pytest'...")
    pytest = subprocess.run(["uv", "run", "pytest", "--maxfail=1", "--tb=short"], capture_output=True, text=True)
    return pytest.returncode, pytest.stdout, pytest.stderr

def loop_execute_audit_test(miniprd_path, superprd_name):
    """
    The core autonomous loop: Execute -> Audit -> Test -> Fix.
    """
    max_iterations = 5
    iteration = 0
    env_vars = {"HYPERGRAPH_PROVENANCE": superprd_name}
    
    while iteration < max_iterations:
        iteration += 1
        print(f"\n[*] Iteration {iteration}: Processing {miniprd_path}")
        
        # 1. Execute (Only strictly required if this is iteration 1, but we assume
        # the Fix agent patches files in place during subsequent loops).
        if iteration == 1:
            execute_success = run_agent_script("hyper_execute", [miniprd_path], env_vars)
            if not execute_success:
                print("[-] Execution agent failed. Retrying...")
                continue
            
        # 2. Audit
        audit_success = run_agent_script("hyper_audit", [miniprd_path], env_vars)
        if not audit_success:
            print("[-] Audit failed. Implementation vs Spec mismatch. Looping...")
            # If audit fails, we should technically fix it, but for now we loop
            continue
            
        # 3. Test (The Oracle)
        exit_code, stdout, stderr = run_oracle_tests()
        
        if exit_code == 0:
            print(f"[+] Tests Passed for {miniprd_path}!")
            return True
        else:
            print(f"[-] Oracle Failed. Engaging Fix Agent...")
            # 4. Fix (Dedicated Node)
            error_log = f"temp_error_{iteration}.log"
            with open(error_log, "w") as f:
                f.write(f"EXIT CODE: {exit_code}\nSTDOUT:\n{stdout}\nSTDERR:\n{stderr}")
                
            # Call the new dedicated fix script
            run_agent_script("hyper_fix", [miniprd_path, "--error-log", error_log], env_vars)
            
    print(f"[!] Max iterations ({max_iterations}) reached. Oracle never satisfied.")
    return False

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python hyper_daemon.py <SuperPRD_Name> <MiniPRD_Path>")
        sys.exit(1)
        
    superprd_name = sys.argv[1]
    miniprd_path = sys.argv[2]
    
    success = loop_execute_audit_test(miniprd_path, superprd_name)
    sys.exit(0 if success else 1)
