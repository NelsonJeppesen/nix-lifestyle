---
name: tuicr
description: Use tuicr for interactive review of local changes or pull requests, and read or add comments in persisted tuicr review sessions.
---

# tuicr Review Workflow

Use `tuicr review` as the agent interface. The human reviews in the TUI; the
agent discovers sessions and reads comments through the CLI.

## Start A Review

1. Determine the repository directory and review target from the request.
2. List existing sessions with `tuicr review list --repo /path/to/repo`.
3. If exactly one relevant session has `"active": true`, use its slug.
4. Otherwise, when running inside herdr, create a tab labeled `oc: tuicr`, run
   `tuicr` there with the repository as its working directory, and leave the
   tab open for the user. Never split a pane.
5. Outside herdr, ask the user to start `tuicr` in the repository.

For uncommitted changes, run `tuicr -w`. For a GitHub pull request, run
`tuicr pr NUMBER`. Use plain `tuicr` when the user should choose the target.

## Read Feedback

After the user says comments are ready, run:

```bash
tuicr review comments --repo /path/to/repo --session SLUG
```

Treat `issue` comments as blocking, `suggestion` comments as optional changes,
`note` comments as questions or context, and `praise` comments as no action.
Reread comments before claiming completion if the review remained open.

## Agent-authored Comments

Only add findings when the user asked the agent to review, and ask first if the
workflow or target session is ambiguous. Identify agent comments explicitly:

```bash
tuicr review add --repo /path/to/repo --session SLUG \
  --target-file src/main.rs --line 42 --side new --type issue \
  --username OpenCode "Handle the empty case here."
```

Prefer line comments, then file comments, then review-level comments. Add
`--end-line` for a range and use `--side old` for removed lines.
