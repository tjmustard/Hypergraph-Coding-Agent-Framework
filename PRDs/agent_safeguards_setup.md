# Securing Repositories for AI Agents: A Setup Guide

When giving autonomous AI agents access to your repositories, you need physical safeguards to prevent them from accidentally pushing broken experimental code to remote servers or committing internal scratch files.

This guide provides the exact scripts and documentation templates you can drop into **any** repository to instantly enforce safe branching and commit hygiene.

---

## 1. Local Git Hooks (The Physical Barriers)

Git hooks run locally and physically intercept `git commit` and `git push` commands. 

### A. Block Internal Files (`pre-commit`)
This prevents agents from committing temporary logs or system specs.
1. Create `.git/hooks/pre-commit`
2. Run `chmod +x .git/hooks/pre-commit`
3. Add the following code:
```bash
#!/bin/bash
set -euo pipefail

# Check all files that are currently staged for commit
staged_files=$(git diff --cached --name-only)

for file in $staged_files; do
    # Define directories you want strictly blocked from version control
    if [[ $file == spec/process/* ]] || [[ $file == spec/handoffs/* ]]; then
        echo "❌ COMMIT BLOCKED!"
        echo "Error: You are trying to commit a forbidden internal file:"
        echo "  -> $file"
        echo "Please unstage this file by running: git restore --staged $file"
        exit 1
    fi
done

exit 0
```

### B. Clean Commit Messages (`commit-msg`)
This intercepts commits and automatically sanitizes them, stripping out auto-generated agent tracking links (like `Claude-Session: ...`).
1. Create `.git/hooks/commit-msg`
2. Run `chmod +x .git/hooks/commit-msg`
3. Add the following code:
```bash
#!/bin/bash
COMMIT_MSG_FILE=$1

# Replace Claude-Session tracking links with standardized label
if grep -q "^Claude-Session: " "$COMMIT_MSG_FILE"; then
    sed -i -e 's|^Claude-Session: .*|Agentic Coding Assisted: Claude Code|' "$COMMIT_MSG_FILE"
fi

# Add additional agent signatures here as needed (e.g., Cursor, Antigravity)

exit 0
```

### C. Prevent Experimental Pushes (`pre-push`)
This is the ultimate safety net. It intercepts `git push` and completely blocks uploading branches that are prefixed with `research/` or `swimlane/`.
1. Create `.git/hooks/pre-push`
2. Run `chmod +x .git/hooks/pre-push`
3. Add the following code:
```bash
#!/bin/bash
while read local_ref local_sha remote_ref remote_sha
do
    # Check if the branch being pushed is restricted
    if [[ $local_ref == refs/heads/research/* ]] || [[ $local_ref == refs/heads/swimlane/* ]]; then
        echo "❌ PUSH BLOCKED!"
        echo "Error: Pushing branches with the 'research/' or 'swimlane/' prefix is strictly forbidden."
        echo "These prefixes are designated for isolated local AI agent work only."
        exit 1
    fi
done
exit 0
```

---

## 2. Agent Documentation (The System Prompts)

Hooks physically block bad actions, but agents need to be *told* the rules so they understand how to navigate the repository properly. Add these rules to your repository's standard context files (e.g., `.agents/rules/` or directly inside `CLAUDE.md` / `GEMINI.md`).

### A. Add the Core Workflow Rule File
Create `.agents/rules/git-workflow.md`:
```markdown
# Git & Workflow Standards

## Protected Branches (DO NOT PUSH)
- **Experimental Branches (`research/*`, `swimlane/*`)**: A `pre-push` hook physically prevents these branches from being uploaded to the remote. 
- **Usage:** Agents MUST use these prefixes for isolated work, refactoring, or running experimental scripts. This guarantees that exploratory code never pollutes the remote repository.

## Protected Paths (DO NOT COMMIT)
- `spec/process/`
- `spec/handoffs/`
These internal paths are blocked by a `pre-commit` hook. Do not attempt to version control them.

## Handling Rejections
If your commit or push is blocked, read the stderr output carefully. Do not force-bypass it. Unstage the forbidden file or rename your branch when you are ready to publish.
```

### B. Explicit Instructions for Agents (CLAUDE.md / GEMINI.md)
To ensure the agent reads and applies the workflow above, inject this snippet into the main instruction file that the agent reads when it enters the repository:

```markdown
### Safe Sandboxing & Automation
When instructed to write experimental code, test tools, or execute destructive scripts, you must **always checkout a branch prefixed with `research/` or `swimlane/`**. 

These prefixes act as an automatic local sandbox. They are intercepted by a repository `pre-push` hook, physically preventing you from accidentally pushing unstable code or broken logic to the remote server. Never execute large automated changes directly on `main` or a feature branch.
```
