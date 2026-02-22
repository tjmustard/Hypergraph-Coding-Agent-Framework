---
description: Create new slash commands on the fly.
---
# /newcommand Workflow

When the user specifies `/newcommand [command_name] [description]`:

1. Acknowledge the creation of the new command.
2. Take note of the command description and add it to your internal rule set and current context.
3. Optionally, propose creating a new workflow file in `.agents/workflows` (e.g., `.agents/workflows/[command_name].md`) to permanently persist the command's behavior if it will be used across multiple sessions.
4. Confirm to the user that the command is ready to use and summarize its intended behavior.
