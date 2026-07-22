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
