import sys
import os
import argparse
from pathlib import Path

# Assuming you have a shared utility for LLM calls in your framework
# from utils import call_llm_router 

def read_file(filepath):
    try:
        with open(filepath, 'r') as f:
            return f.read()
    except Exception as e:
        return f"[Error reading {filepath}: {e}]"

def build_fix_prompt(miniprd_path, error_log_path, superprd_name=None):
    """
    Constructs a highly contextual prompt triangulating intent and failure.
    """
    miniprd_content = read_file(miniprd_path)
    error_content = read_file(error_log_path)
    
    # Attempt to locate the parent SuperPRD for global context
    superprd_content = "SuperPRD context not provided."
    if superprd_name:
        # Assuming standard naming convention from MasterSOP
        superprd_path = Path(miniprd_path).parent.parent / "drafts" / f"SuperPRD_{superprd_name}.md"
        if superprd_path.exists():
            superprd_content = read_file(superprd_path)

    prompt = f"""
You are the Hypergraph Framework Bug Fix Agent. Your task is to resolve a test/compilation failure.
You MUST adhere strictly to the original intent of the specification. Do not invent new features.

--- GLOBAL CONTEXT (SuperPRD) ---
{superprd_content}

--- IMMEDIATE INTENT (MiniPRD) ---
{miniprd_content}

--- FAILURE TRACE (stderr/stdout) ---
{error_content}

INSTRUCTIONS:
1. Analyze the Failure Trace against the Immediate Intent.
2. Formulate a hypothesis for why the code failed.
3. Apply the necessary modifications to the source code to resolve the error while maintaining specification alignment.
4. Output ONLY the corrected code blocks or instructions. Do not apologize or explain.
"""
    return prompt

def execute_fix(miniprd_path, error_log_path):
    print(f"    [FIX AGENT] Analyzing failures for {os.path.basename(miniprd_path)}...")
    
    # Extract provenance to find the SuperPRD
    superprd_name = os.environ.get("HYPERGRAPH_PROVENANCE")
    
    prompt = build_fix_prompt(miniprd_path, error_log_path, superprd_name)
    
    # TODO: Wire this to your actual LLM routing logic
    # response = call_llm_router(prompt, skill="hyper_fix")
    print(f"    [FIX AGENT] Placeholder: LLM has analyzed the trace and applied fixes.")
    
    # Clean up the temporary error log
    if os.path.exists(error_log_path):
        os.remove(error_log_path)
        
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Hypergraph Bug Fix Agent")
    parser.add_argument("miniprd", help="Path to the associated MiniPRD")
    parser.add_argument("--error-log", required=True, help="Path to the execution error trace")
    
    args = parser.parse_args()
    
    success = execute_fix(args.miniprd, args.error_log)
    sys.exit(0 if success else 1)
