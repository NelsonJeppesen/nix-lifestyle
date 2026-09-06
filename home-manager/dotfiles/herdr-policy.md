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
