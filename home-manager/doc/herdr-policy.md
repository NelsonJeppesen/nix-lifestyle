# Herdr Local Policy

This local policy overrides the bundled Herdr skill's layout defaults.
Use named tabs, not sibling splits, for commands and delegated agents.

## Preconditions

- Verify `HERDR_ENV=1` before controlling Herdr. Outside Herdr, ask the
  user to run interactive commands; do not run them through a tool without a TTY.
- For explicitly requested Herdr work, load the bundled `herdr` skill.
  It is not automatically loaded by `HERDR_ENV`. For other interactive tasks
  covered by this policy, use `herdr --help` and command-group help directly.
- Identify the caller with `herdr pane current --current`, never UI focus.
  Use its returned workspace ID (important after moving a pane); normally this
  matches `HERDR_WORKSPACE_ID`. Preserve the caller's working directory.

## Commands In Tabs

Use a dedicated tab for sudo, Terraform init/plan/apply/destroy, authentication,
SSH or Git commands that might prompt, Home Manager/NixOS switches, REPLs,
servers, and log watchers. Keep short noninteractive commands in the tool shell.

- Create with `herdr tab create --workspace <caller-workspace> --cwd <cwd>
  --label "oc: <description>" --no-focus`. Pi uses `pi: ` instead of `oc: `.
  Parse `.result.tab.tab_id` and `.result.root_pane.pane_id`; never invent IDs.
- Run ordinary commands with `herdr pane run <pane-id> <command>`.
  Quote the command so variables intended for the child shell expand there.
- Read progress with `herdr pane read <pane-id> --source recent-unwrapped`.
  For finite commands, choose a fresh alphanumeric nonce and send this pattern:
  `( COMMAND ); result=$?; printf '\n__HERDR_DONE_<nonce>__:%s\n' "$result"`.
  This emits a status on success or failure, without exiting the tab's shell.
- Wait using `herdr pane wait-output <pane-id>
  --regex '(?m)^__HERDR_DONE_<nonce>__:[0-9]+\r?$' --timeout 120000`.
  Anchoring avoids matching the echoed command; the nonce avoids stale output.
  Read the status and output, not just a successful wait. Timeout means inspect
  progress, not completion; do not close or rerun a still-running command.
- For passwords, 2FA, or device authorization, show the user the prompt/URL/code
  verbatim and focus the owned tab with `herdr tab focus <tab-id>`. Never enter
  credentials or approve an agent's permission dialog on the user's behalf.

## Delegated Agents

- Create a named tab as above, then use `herdr agent start <unique-name>
  --kind opencode --pane <pane-id>` (or `--kind pi`). Do not scrape prompts or
  use `pane run` to feed tasks into agent UIs.
- After successful startup, submit with `herdr agent prompt <name> "<task>"
  --wait --timeout 120000`. Its settled states include idle, done, and blocked;
  blocked is not successful task completion.
- On startup/prompt failure, inspect `herdr agent get <name>` and
  `herdr agent read <name> --source recent-unwrapped`. Ask the user about
  approval/authentication prompts. Do not blindly retry or send raw input.

## Ownership And Cleanup

- Keep background tabs unfocused unless the user needs to interact.
- Close only tabs created by this agent, after the command has finished and
  needed output is collected: `herdr tab close <tab-id>`.
- Leave running servers/watchers and auth-blocked tabs open; tell the user.
  Never stop the Herdr server to clean up a task.
- Do not split unless explicitly requested. If needed, split down, not right.

## Parallel Git Work

- Give independent editing tasks separate Git worktrees and Herdr Spaces; use
  named tabs inside each Space for its agent, tests, and shell.
- Record each task's branch, worktree path, owner, and validation command before
  delegation. Avoid two writers in one checkout; agree on shared-file ownership.
- Keep build output and temporary files inside the owning worktree. Assign
  distinct ports to concurrent development servers.
- Review and integrate one branch at a time. A finished agent or clean working
  tree does not prove commits are merged, pushed, or safe to delete.
- ARC actions live under Ctrl-Shift-E; Ctrl-Shift-G opens project templates.
  After a failed Jira step in ARC close, use the printed `herdr-arc finish`
  recovery command. It updates Jira without requiring or removing a checkout.

## Worktree Handoff

Create one handoff per task worktree before delegation. It records the current
state, not a chronological journal; update fields in place and omit credentials
or raw private logs.

```sh
handoff="$(git rev-parse --git-path HANDOFF.md)"
test -e "$handoff" || cp ~/.config/herdr/worktree-handoff.md "$handoff"
```

The path returned by Git is local to this worktree's metadata. Do not place the
handoff in tracked source or use a shared repository-wide file for parallel tasks.
Give the next agent the absolute worktree path and ask it to resolve the handoff
there with the same Git command.

1. Record the goal, acceptance checks, owner, branch/base commit, Space/tab IDs,
   owned files, build output directory, and allocated ports.
2. Keep one writing agent per worktree. Review agents may read that checkout;
   another implementation task gets its own branch, worktree, Space, and handoff.
3. Before handing over, record uncommitted changes, exact validation commands
   and results, blockers, running processes to preserve, and the next action.
4. The receiving agent checks `git status --short --branch` and current HEAD
   against the handoff before editing, then updates ownership. Do not reset or
   overwrite unexpected changes to make the record match.
5. Integrate reviewed commits one branch at a time, rerun affected checks on the
   integration branch, and record merge/push status before any checkout cleanup.

Herdr Spaces are task boundaries. Name the Space after its branch or ticket;
use `agent`, `test`, and `shell` tabs within it. Prefer opening the existing Space
for a branch instead of creating a duplicate agent in the same checkout.
