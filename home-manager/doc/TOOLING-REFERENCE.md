# Home Manager Tooling Reference

This is the practical reference for the Git, pull-request, OpenCode, Pi,
Herdr, Neovim, and supporting shell tooling added or changed
between 2026-07-19 and 2026-08-01.

The current configuration is authoritative. The history section explains why
the tools exist and what they replaced. More focused references remain in:

- `doc/neovim-cheatsheet.md`
- `ai/dotfiles/herdr-usage.txt`
- `doc/AGENTS.md`

## Quick Choice

<!-- markdownlint-disable MD013 -->

| Goal | Use |
| --- | --- |
| Review local changes yourself | `git diff` or `vu` |
| Browse your PRs and review requests | `gh-dash` |
| Open unstaged and untracked files in Neovim | `vu` |
| Open files changed from local `main` in Neovim | `vm` |
| Resume the last OpenCode conversation | `oc` |
| Pick a recent OpenCode conversation | `os` |
| Start Pi or continue it | `p` / `pc` |
| Open an agent or shell in a new Herdr tab | `Ctrl-Shift-y` Claude Code, `-o` OpenCode, `-x` Codex, `-p` Pi, `-s` shell |
| Start DevOps work on an ARC ticket in its own worktree | `Ctrl-Shift-e`, then DevOps: New ARC ticket / Worktree for existing ARC / Open ARC branch |
| Watch every agent session from one dashboard | `Super-a` (Agent Deck window) or `ad` |
| Split work across parallel agent threads | `Ctrl-Shift-a` in Herdr (Herdr Projects) |
| Open a whole templated workspace, or run a quick action | `Ctrl-Shift-g` / `Ctrl-Shift-e` in Herdr (herdr-plus) |
| Navigate to a known project | `z NAME` or `cd ~NAME` |
| Search source structurally | `ast-grep` |
| Find which Nix package supplies a command | `nix-locate bin/COMMAND` |
| Temporarily run an uninstalled command | `, COMMAND` |
| Lint the current Neovim buffer | `<leader>ll` |

<!-- markdownlint-enable MD013 -->

## Recommended Daily Workflows

### Local changes: human review

For selective staging, including new files:

```bash
git app
```

This lets you select untracked files with fzf, marks them intent-to-add, then
runs `git add -p`.

### GitHub dashboard

```bash
gh-dash
```

The dashboard includes open PRs authored by you and open PRs requesting your
review.

## Git

### Git aliases

| Command | Purpose |
| --- | --- |
| `git pu` | `git push` |
| `git puf` | Safer force push using `--force-with-lease --force-if-includes` |
| `git br` | fzf-pick recent local branches and `git switch` |
| `git app` | Select untracked files, then interactively stage patches |
| `git open [PATH]` | Open the current GitHub branch/path in a browser |

The community GitAlias collection is also included globally.

Current defaults relevant to daily work:

- Every commit is SSH-signed.
- Conflict markers use `zdiff3`, which includes the merge base.
- Branches sort by most recent commit.
- Pulls are fast-forward-only.
- Push defaults to the current branch and automatically establishes upstream.
- GitHub, GitLab, and Bitbucket HTTPS URLs are rewritten to SSH.
- Plaintext `credential.helper = store` is no longer configured.

`git open` only supports a GitHub `origin`; its optional path is not URL
escaped, and detached HEAD behavior is limited.

## OpenCode

### Starting and resuming

| Command | Action |
| --- | --- |
| `o` | Start OpenCode |
| `oc` | Continue the previous conversation |
| `os` | fzf-pick one of the 16 most recently updated sessions |
| `ou` | Remove cached OpenCode plugin npm packages |
| `Ctrl-Shift-o` | Open OpenCode in a new Herdr tab at the active directory |

The Home Manager default model is `github-copilot/gpt-5.6-sol`. A
repository-local `opencode.json` can override it; this repository currently
uses `openai/gpt-5.6-sol`.

OpenCode pre-allows external file access under `~/source/**` and `~/tmp/**`.
This removes repetitive directory prompts; it is not permission to expose
credentials, escalate privileges, or perform arbitrary destructive actions.

There are no custom agent definitions in `ai/opencode.nix`. Pi is a separate
coding agent.

The former `oc-standup` workflow was removed.

### MCP servers

<!-- markdownlint-disable MD013 -->

| Server | OpenCode | Notes |
| --- | ---: | --- |
| Atlassian | Enabled | Interactive OAuth for Jira/Confluence |
| GitHub | Enabled | Uses `GITHUB_TOKEN`; PR, issue, repository, and Actions tools |
| Terraform | Enabled | Registry/provider/module documentation tools |
| Memory | Enabled | Persistent graph at `~/.local/share/mcp-memory/memory.json` |
| Kubernetes | Disabled | Enable deliberately when cluster access is needed |
| Slack read | Disabled | OpenCode server `slack-read`; explicit read-only tool allowlist |
| Slack write | Disabled | Mutating tools; enable deliberately and temporarily |

<!-- markdownlint-enable MD013 -->

The comments near the MCP declaration currently say that all servers default
to disabled, but the actual booleans above are authoritative. In particular,
Terraform is enabled.

Persistent memory is shared across sessions. Store durable conventions,
architectural decisions, stable environment facts, and recurring gotchas.
Never store secrets, tokens, transient status, or large file contents.

### Slack credentials

When deliberately enabling Slack MCP support:

```bash
eval "$(slack-stealth-tokens)"
slack-stealth-tokens --envrc >> secret.env
```

The command prints browser-session secrets to stdout. Treat the output as a
secret and never commit it. Read-only Slack and mutating `slack-write` are
separate disabled configurations; registering the write tools makes those
operations live without channel restrictions.

## Pi

Pi is installed alongside OpenCode for testing, not as a replacement.

| Command | Action |
| --- | --- |
| `p` | Start Pi |
| `pc` | Continue Pi |
| `Ctrl-Shift-p` | Open Pi in a new Herdr tab at the active directory |

Pi has a pinned, Nix-built MCP adapter and shares the Herdr skill with
OpenCode. Its MCP servers start lazily and include Atlassian, GitHub,
Terraform, persistent memory, and read-only Slack.

Pi does not currently receive Kubernetes or Slack-write. Pi and OpenCode share
the same persistent memory JSON file. Herdr reports Pi's
blocked, working, and done states in the sidebar.

## Herdr

Herdr is the terminal multiplexer around agents and interactive review tools.
Kitty intentionally delegates tabs, panes, sessions, and most `Ctrl-Shift`
bindings to Herdr.

### Commands

| Command | Action |
| --- | --- |
| `h` | Start or attach Herdr |
| `hr HOST` | Attach remotely |
| `ho` | Reinstall Herdr's OpenCode integration |
| `ws` | Create a workspace rooted at `~/source` |
| `hrf COMMAND...` | Run a command in a new focused tab |
| `hrn COMMAND...` | Run a command in a new background tab |

### Direct keys

| Key | Action |
| --- | --- |
| `Ctrl-Shift-Left/Right` | Previous/next tab |
| `Ctrl-Shift-Up/Down` | Previous/next workspace |
| `Ctrl-Shift-n` | New workspace |
| `Ctrl-Shift-[` / `]` | Previous/next agent |
| `Ctrl-Shift-b` | Toggle sidebar |
| `Ctrl-Shift-r` | Resize mode |
| `Ctrl-Shift-h/j/k/l` | Focus pane left/down/up/right |
| `Ctrl-Shift-Enter` | Split right |
| `Ctrl-Shift-d` | Split down |
| `Ctrl-Shift-Backspace` | Close pane |
| `Ctrl-Shift-z` | Zoom pane |
| `Ctrl-Shift-,/.` | Previous/next pane |
| `Ctrl-Shift-y` | Claude Code tab at active directory |
| `Ctrl-Shift-o` | OpenCode tab at active directory |
| `Ctrl-Shift-x` | Codex tab at active directory |
| `Ctrl-Shift-p` | Pi tab at active directory |
| `Ctrl-Shift-s` | Shell tab at active directory (replaces `Ctrl-Shift-t`) |
| `Ctrl-Shift-a` | Herdr Projects popup |
| `Ctrl-Shift-g` | herdr-plus workspace templates |
| `Ctrl-Shift-e` | herdr-plus quick actions |
| `F1` | Edit scrollback |

### Prefix keys

The prefix is `Ctrl-b`; release it before pressing the action key.

| Key | Action |
| --- | --- |
| `w` | Workspace picker |
| `g` | Goto picker |
| `e` | Edit scrollback |
| `Shift-p` | Rename pane |
| `Shift-t` | Rename tab |
| `1..9` | Jump to tab |
| `Shift-x` | Close tab |
| `Shift-w` | Rename workspace |
| `Shift-d` | Close workspace |
| `Shift-g` | New worktree |
| `s` | Settings |
| `q` | Detach while processes continue |
| `Shift-r` | Reload configuration |
| `?` | Show the live keymap |

Kitty reserves `Ctrl-Shift-c/v` for the clipboard and
`Ctrl-Shift-=`, `Ctrl-Shift-+`, and `Ctrl-Shift--` for font size. New panes
inherit the active directory but start new shells, so direnv evaluates once per
pane.

### Rules for agents

- Only control Herdr when `HERDR_ENV=1`.
- Run interactive, authenticated, or long-lived commands in a named tab whose
  label starts with `oc:`.
- Do not fall back to a non-TTY shell for commands that may prompt.
- Prefer tabs. Do not split panes unless a purpose-built workflow requires it.
- Never send passwords, tokens, 2FA values, or device codes on the user's
  behalf. Focus the tab and let the human complete authentication.
- Re-read current tab and pane IDs; Herdr IDs can compact after closure.
- Close temporary tabs after collecting their output, but leave active servers,
  auth prompts, and user-facing TUIs open.

### Herdr Projects

The `herdr-projects` plugin puts one coordinator conversation in front of
parallel worker threads. Each thread runs in its own pane on its own git
worktree or folder, and every thread gets the project's shared instructions
and memory. The sidebar groups threads by what needs you. A project is a folder
under `~/.herdr-projects/<name>/`.

| Command | Action |
| --- | --- |
| `Ctrl-Shift-a` | Projects popup: open, create, or review projects |
| `herdr-projects new "NAME" --repo PATH` | Create a project for a repository |
| `herdr-projects open SLUG` | Open a project and start its coordinator |
| `herdr-projects doctor` | Check the setup |

Nix builds the plugin from the pinned `herdr-projects` flake input.
Activation links it with `herdr plugin link` and runs
`herdr-projects configure --hooks-only`. That adds the progress hooks to
`~/.claude/settings.json` and `~/.codex/hooks.json` and links the
`autoproject` skill. The rest of what `configure` normally writes (sidebar rows,
tab-bar count, popup key) is declared in `ai/herdr.nix`, so:

- Do not run `herdr-projects configure` without `--hooks-only`, or `update`. The
  first refuses Home Manager's read-only `config.toml`, and the second cannot
  rebuild a store path. To upgrade, bump the flake input.
- `doctor` reports the sidebar as "not configured" because the plugin's journal
  has no entry for that file. The rows are there; ignore that one line.
- `herdr-projects unconfigure` removes the hooks and skill links. The next
  switch adds them back.

### herdr-plus

`herdr-plus` adds two pickers. Projects builds a whole workspace, every tab,
pane, and startup command, from a template. Quick Actions runs a one-off
command in the directory you launched it from. Both are declared in
`ai/herdr-plus.nix`, which writes them to
`~/.config/herdr/plugins/config/cloudmanic.herdr-plus/`. Add a template or
action there, not by hand in that directory.

| Picker | Entries |
| --- | --- |
| Projects (`Ctrl-Shift-g`) | DevOps, DevOps: Terraform, nix-lifestyle |
| Quick actions (`Ctrl-Shift-e`) | New tab (any launcher), new ARC ticket + worktree, worktree for an existing ARC, open an ARC branch, open ARC ticket, validate changes, `mise run test:agents`/`test:harness`, open a harness `HANDOFF.md`, read-only k9s, AWS SSO login, open PR, git status |

- **DevOps: New ARC ticket + worktree** asks for a title. A headless Claude
  Code (Haiku, Atlassian MCP only, claude.ai login) files an ARC Task assigned
  to you. Its key and the slugged title become the branch, e.g.
  `ARC-4100-rotate-eks-node-amis`. The git fetch runs while the ticket is
  being filed.
- **DevOps: Worktree for existing ARC** takes `1234 short topic`. If that
  branch already exists, it opens instead of failing.
- **DevOps: Open ARC branch** lists ARC branches: open Spaces first, then
  worktrees, local branches, and origin-only branches, newest first. Picking
  one focuses its Space, reopens its worktree, or checks it out.
- All Herdr worktrees, ARC or not, live in `~/source/worktrees/<repo>/`
  (`worktrees.directory` in `ai/herdr.nix`, instead of `~/.herdr/worktrees`).
  devops' `.envrc` runs `source_up`, and the API keys, GitHub token, and sticky
  AWS profile come from `~/source/.envrc`, which only a checkout under
  `~/source` inherits. direnv whitelists that root, so no `direnv allow` is
  needed. Each new ARC checkout also gets `mise trust`, the `terraform` submodule (using the main
  checkout's objects), and copies of `.envrc.local` and
  `.claude/settings.local.json`. New Spaces start OpenCode; set
  `HERDR_ARC_AGENT` in the Herdr server's environment to start something else.
- Quick actions that need devops' environment (`bin/`, `KUBECONFIG`,
  `AWS_CONFIG_FILE`) run through `direnv exec`, because the plugin inherits the
  Herdr server's environment rather than the pane's.
- The plugin's worktree auto-layouts are deliberately unused. They fire on
  every `herdr worktree create`, including the ones Herdr Projects makes for its
  threads, and would add tabs to those Spaces.
- To upgrade, bump the `herdr-plus` flake input (and `vendorHash` if Go
  dependencies changed). Activation relinks the plugin with `herdr plugin link`.

## OpenRig

OpenRig provides the `rig` CLI and terminal dashboard for teams of Claude Code
and Codex agents. Run `rig` to open its interactive dashboard. The pinned npm
release and SQLite native addon are built with Node 24 through Nix, and the
commands include tmux in their runtime path.

| Command | Purpose |
| --- | --- |
| `rig` | Open the terminal dashboard |
| `rig doctor` | Check the local runtime and agent prerequisites |
| `rig setup --dry-run` | Preview setup changes |
| `rig daemon start --no-kernel` | Start the local daemon without booting kernel agents |
| `rig daemon status` | Check daemon health |
| `rig up <spec-or-library-name> --plan` | Preview a team launch |

The daemon starts on demand; Paperclip has the continuously running service.
OpenRig stores local state in `~/.openrig/`. Use the dashboard to configure and
launch teams. Review the setup preview before applying `rig setup`, which can
change agent trust settings. Update the `openrig` flake input, dependency lock,
and package hash to upgrade through Home Manager.

## Paperclip

Paperclip runs continuously as the `paperclipai` systemd user service. Open
<http://127.0.0.1:3100> to create a company, add agents, and assign work.
The dashboard listens on loopback. User lingering keeps it running after
logout and starts it at boot; it resumes after the laptop wakes from sleep.

| Command | Purpose |
| --- | --- |
| `systemctl --user status paperclipai` | Check the service |
| `journalctl --user -u paperclipai -f` | Follow server logs |
| `systemctl --user restart paperclipai` | Restart the server |
| `paperclipai doctor` | Check the instance configuration and database |

The pinned release, Node 24, and PostgreSQL 18 come from Nix. Update the
`paperclip` flake input, dependency lock, and package hash to upgrade. Home
Manager owns the service and CLI; use `systemctl` to manage this service.
Instance configuration, database, uploads, secrets, and automatic backups
live under `~/.paperclip/instances/default/`. First startup generates the
local configuration and secrets there. Agent CLI logins remain in their
normal home directories; add the agents and their working directories in
the dashboard.

## Agent Deck

Agent Deck is the alternative to Herdr for agent work: one dashboard of agent
sessions, each running in its own tmux session. It gets its own Kitty window
with class `agent-deck`, so run-or-raise keeps `Super-e` (Herdr) and `Super-a`
(Agent Deck) apart.

### Commands

| Command | Action |
| --- | --- |
| `Super-a` | Raise or launch the Agent Deck Kitty window |
| `kitty-agent-deck` | Launch that window from a shell |
| `ad` | Run the dashboard in the current terminal |
| `ad add . -c opencode` | Add the current directory as an OpenCode session |
| `ad pi-hooks install` | Install the Pi status extension (one time, manual) |

### Dashboard keys

| Key | Action |
| --- | --- |
| `n` | New session (`Enter` advances fields; `Ctrl-s` creates) |
| `Enter` | Attach to the selected session |
| `Ctrl-q` | Detach back to the dashboard |
| `f` / `F` | Fork (quick / dialog) |
| `/` | Fuzzy-search sessions |
| `r` / `R` | Rename / restart |
| `d` | Delete |
| `?` | Full help |

Inside a session the tmux prefix is `Ctrl-b`; `Ctrl-b 1..6` jumps to a
session waiting for input.

### Managed behavior

- Nix owns the version. Update checks, auto-install, and self-restart are off;
  bump the `agent-deck` flake input and `vendorHash` instead of running
  `agent-deck update`.
- `config.toml` is a read-only Home Manager file, so the TUI settings panel
  (`S`) cannot save. Edit `ai/agent-deck.nix`.
- Agents start through an interactive zsh (`launch_shell`), so they see the
  same session variables and MCP tokens as a Herdr pane.
- Telemetry is disabled and its consent prompt never appears.
- The first TUI start asks before adding status hooks to
  `~/.claude/settings.json`. The hook runs the bare `agent-deck hook-handler`
  through `PATH`, so it survives Nix store path changes.

## OpenCode Web Access

### Laptop service through Cloudflare

Home Manager runs OpenCode's web UI on loopback:

```text
127.0.0.1:4097
```

Port 4097 avoids the normal interactive server's port 4096. A per-host
`cloudflared` user service connects it to Cloudflare Tunnel and Zero Trust
Access. Cloudflare email OTP is the authentication boundary; OpenCode itself is
not. The core UI uses server-sent events, which work through the Access cookie.

Configured hostnames:

| NixOS host | Public hostname |
| --- | --- |
| `lg-gram-14-2022` | `lg-gram-14-oc.jeppesen.io` |
| `lg-gram-pro-17-2025` | `lg-gram-17-oc.jeppesen.io` |

An unmapped host starts no connector. A mapped host with a missing token causes
the tunnel unit to fail and retry. Tunnel/DNS/Access infrastructure is managed
outside this repository in `~/source/personal/terraform/core/`.

### Headless `opencode` machine through Tailscale

The NixOS `opencode` host is a separate deployment. It serves loopback port
4096 and publishes it through `tailscale serve`; tailnet ACLs are its
authentication gate.

It imports `home-manager/ai/opencode.nix` and `home-manager/ai/mcp.nix`, but not
the separate `ai/pi.nix`, `ai/herdr.nix`, or `cli/git.nix` modules. Therefore it
does not automatically receive Pi even though its core OpenCode settings and
shared MCP catalogue match.

## Neovim

`nvim`, `vim`, and `vi` use the nvf configuration in `neovim/nvf.nix`.
It sets `$EDITOR` and `$VISUAL` to Neovim.

Telescope provides search, Neo-tree provides the file tree, and Trouble
shows diagnostics. Formatting and extra diagnostics are enabled through
nvf's language modules. Language settings are explicit in `neovim/nvf.nix`;
installing a CLI language server does not enable it in the editor.

Avante is enabled. Copilot and opencode.nvim are not enabled; use OpenCode
from Herdr.

See `doc/neovim-cheatsheet.md` for shortcuts and enabled languages.

## Shell and Supporting CLI Tools

### Navigation

Zoxide supplies frecency-based navigation:

```bash
z terraform
z nix-lifestyle
zi
```

Named Zsh directories are generated for `~/source`, its immediate children,
and immediate children under `~/source/personal`:

```bash
cd ~s
cd ~terraform
cd ~nix-lifestyle
```

If two directories have the same basename, the final named-directory
registration wins.

### Open changed files

```bash
vu   # unstaged tracked files plus untracked files
vm   # files differing from local main plus untracked files
```

Both commands:

- Change to the repository root.
- Handle unusual filenames with NUL-delimited Git output.
- Skip deleted paths and directories.
- Deduplicate paths.
- Open all matches in Neovim.
- Print `No matching files.` when empty.

`vu` omits staged-only files. `vm` requires a local ref named exactly `main`
and compares directly to it, not `origin/main` or an explicitly calculated
merge base. Keep local `main` current when relying on this view.

### Viewing, searching, and temporary packages

```bash
bat file.nix
bat --plain --paging=never file

ast-grep --pattern 'console.log($A)' --lang javascript
ast-grep scan

nix-locate bin/some-command
, jq
, cowsay hello
```

Use `ast-grep` when a text search would also match comments, strings, or
unrelated syntax. `nix-locate` uses a weekly prebuilt binaries-only index, so
very recent nixpkgs changes can lag. Comma runs software from Nix temporarily
without adding it permanently to Home Manager.

## Troubleshooting

### OpenCode cannot use GitHub tools

- Confirm `GITHUB_TOKEN` is exported in the OpenCode process environment.
- Restart OpenCode after changing Home Manager MCP configuration.
- Use `gh auth status` to diagnose the underlying authentication.

### Neovim does not show lint diagnostics

- Verify the filetype with `:set filetype?`.
- Save the buffer or run `<leader>ll`.
- Open `:LspInfo` for LSP state; nvim-lint itself is separate from LSP.
- Use Trouble with `<leader>xX` or `<leader>xx` to inspect collected findings.

### `vm` reports that `main` does not exist

Create or fetch a local `main` ref, or use `vu` when the intended scope is only
unstaged and untracked work. `vm` intentionally does not infer a remote default
branch.

### Long-running OpenCode work stops after locking the laptop

On AC power, GNOME is configured to lock/blank after 15 minutes but delay
automatic suspend for two hours. Battery suspend behavior is unchanged. The
comment in `gnome/gnome.nix` currently says three hours, but `7200` seconds and the
commit subject both indicate two hours.

## What Changed and Why

Baseline for this guide: the last commit before the window was
`e9372f7` on 2026-07-17.

<!-- markdownlint-disable MD013 -->

| Date | Commit | Effect |
| --- | --- | --- |
| 2026-07-19 | `8f93ea7` | Tuned Herdr/Kitty and added mobile relay prerequisites. |
| 2026-07-19 | `4a01c31` | Added direct Herdr sidebar and resize keybindings. |
| 2026-07-19 | `4c9ee77` | Hardened shell/Herdr commands, removed plaintext Git credential storage, moved F1 scrollback handling to Herdr, and cleaned stale Neovim configuration. |
| 2026-07-19 | `4c8cd02` | Added the loopback OpenCode web service and per-laptop Cloudflare Tunnel connector. |
| 2026-08-01 | `8e694a7` | Updated flake pins and added nix-index-database, Pi MCP adapter, and a terminal review input. |
| 2026-08-01 | `26f6d42` | Added the Ansible suite, ast-grep, and prebuilt nix-index integration. |
| 2026-08-01 | `8fb22c9` | Added Pi, gh-dash integration, modern agent tool guidance, and removed `oc-standup`. |
| 2026-08-01 | `4b79708` | Added Ansible/Jinja LSP support and save-time nvim-lint; removed hardtime.nvim. |
| 2026-08-01 | `4d3e9ea` | Added zoxide, bat, named directories, `vu`/`vm`, and the Pi Herdr launcher. |
| 2026-08-01 | `07050ad` | Imported the new feature modules and pruned unused packages. |
| 2026-08-01 | `17093fe` | Added Chromium v11 cookie decryption and padding validation to `slack-stealth-tokens`. |
| 2026-08-01 | `e3ea3e2` | Delayed AC suspend so long-running OpenCode work survives idle lock. |

<!-- markdownlint-enable MD013 -->

### Superseded tools and workflows

- The `git wt` alias, shell `wt` function, and lazyworktree integration were
  removed. Herdr provides worktree creation via `prefix+shift+g`.
- `oc-standup` and its redaction/collector files were removed. GitHub work now
  centers on `gh-dash`.
- `hardtime.nvim` was removed.

## Configuration Map

<!-- markdownlint-disable MD013 -->

| Area | Main files |
| --- | --- |
| Git | `cli/git.nix` |
| GitHub dashboard | `cli/gh-dash.nix` |
| OpenCode and MCP servers | `ai/opencode.nix` |
| Pi and its MCP adapter | `ai/pi.nix` |
| Herdr | `ai/herdr.nix`, `ai/dotfiles/herdr-usage.txt`, `doc/herdr-policy.md`, bundled package skill |
| Herdr Projects | `ai/herdr-projects.nix`, plugin rows and key in `ai/herdr.nix` |
| herdr-plus | `ai/herdr-plus.nix`, `ai/bin/herdr-arc`, keys in `ai/herdr.nix` |
| Agent Deck | `ai/agent-deck.nix`, `gnome/dotfiles/shortcuts.conf` |
| Paperclip | `ai/paperclip.nix`, `ai/paperclip/package.nix`, `ai/paperclip/package-lock.json` |
| OpenRig | `ai/openrig.nix`, `ai/openrig/package.nix`, `ai/openrig/package-lock.json` |
| Neovim | `neovim/nvf.nix`, `doc/neovim-cheatsheet.md` |
| zoxide and shell helpers | `cli/zoxide.nix`, `cli/zsh.nix`, `cli/dotfiles/zsh-named-dirs.zsh` |
| bat | `cli/bat.nix` |
| ast-grep | `cli/development-tools.nix` |
| nix-index and comma | `cli/nix-index.nix` |
| Feature imports and packages | `home.nix`, `<category>/default.nix`, `<category>/packages.nix`, `other.nix` |
| Input pins and special arguments | `flake.nix`, `flake.lock` |

<!-- markdownlint-enable MD013 -->

After changing these modules, format touched Nix files with `nixfmt` and test
with a Home Manager build/switch appropriate to the task. Interactive switching
belongs in a Herdr tab because it may be long-running and can involve prompts.
