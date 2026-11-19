# Home Manager Tooling Reference

This is the practical reference for Git, pull requests, OpenCode, Pi,
Herdr, Neovim, and the supporting shell tools. The current configuration is
authoritative; Git and the changelog hold change history. Focused references:

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
| Finish an ARC worktree: remove the checkout, mark the ticket Done | `Ctrl-Shift-w` in Herdr |
| Watch every agent session from one dashboard | `Super-a` (Agent Deck window) or `ad` |
| Split work across parallel agent threads | Separate Herdr Spaces/worktrees; optional Herdr Projects provides a coordinator |
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
- Credentials use the configured authentication tools; Git does not use plaintext credential storage.

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
repository-local `opencode.json` can override it. Inspect the active client
configuration when a model or tool differs from the managed defaults.

OpenCode pre-allows external file access under `~/source/**` and `~/tmp/**`.
This removes repetitive directory prompts; it is not permission to expose
credentials, escalate privileges, or perform arbitrary destructive actions.

There are no custom agent definitions in `ai/opencode.nix`. Pi is a separate
coding agent.

### MCP servers

<!-- markdownlint-disable MD013 -->

| Server | OpenCode | Notes |
| --- | ---: | --- |
| Atlassian | Enabled | Interactive OAuth for Jira/Confluence |
| GitHub | Enabled | Uses `GITHUB_TOKEN`; PR, issue, repository, and Actions tools |
| Terraform | Enabled | Registry/provider/module documentation tools |
| Memory | Enabled | Persistent graph at `~/.local/share/mcp-memory/memory.json` |
| WorkIQ | Enabled | Microsoft 365 queries; tenant consent may be required |
| Kubernetes | Disabled | Enable deliberately when cluster access is needed |

<!-- markdownlint-enable MD013 -->

The table describes the Home Manager catalogue. A separate launcher or local
client configuration can override it; inspect the effective client setup when
a declared tool is absent.

Persistent memory is shared across sessions. Store durable conventions,
architectural decisions, stable environment facts, and recurring gotchas.
Never store secrets, tokens, transient status, or large file contents.

## Pi

Pi is installed alongside OpenCode for testing, not as a replacement.

| Command | Action |
| --- | --- |
| `p` | Start Pi |
| `pc` | Continue Pi |
| `Ctrl-Shift-p` | Open Pi in a new Herdr tab at the active directory |

Pi has a pinned, Nix-built MCP adapter and shares the Herdr skill with
OpenCode. Its MCP servers start lazily and include Atlassian, GitHub,
WorkIQ, Terraform, and persistent memory.

Pi does not receive Kubernetes tools. Pi and OpenCode share
the same persistent memory JSON file. Herdr reports Pi's
blocked, working, and done states in the sidebar.

## Herdr

Herdr is the local terminal multiplexer around agents and interactive review
tools. Its remote relay, tunnel, and mobile-relay provisioning are disabled.
Kitty intentionally delegates tabs, panes, sessions, and most `Ctrl-Shift`
bindings to Herdr.

### Commands

| Command | Action |
| --- | --- |
| `h` | Start or attach Herdr |
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
| `Ctrl-Shift-s` | Shell tab at active directory |
| `Ctrl-Shift-a` | Herdr Projects popup, only with the optional module enabled |
| `Ctrl-Shift-g` | herdr-plus workspace templates |
| `Ctrl-Shift-e` | herdr-plus quick actions |
| `Ctrl-Shift-w` | ARC: close worktree + ticket |
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

### Herdr Projects (optional)

`ai/default.nix` leaves `herdr-projects.nix` disabled. Its commands, hooks, and
`Ctrl-Shift-a` binding require enabling that import and rebuilding first.
The following describes its configured behavior when enabled.

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

When enabled, Nix builds the plugin from the pinned `herdr-projects` flake input.
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
| Quick actions (`Ctrl-Shift-e`) | ARC: New ticket + worktree; Worktree for my open ticket; Open worktree; Close worktree + ticket |

- **ARC: New ticket + worktree** asks for a title. A headless Claude
  Code (Haiku, Atlassian MCP only, claude.ai login) files an ARC Task assigned
  to you. Its key and the slugged title become the branch, e.g.
  `ARC-4100-rotate-eks-node-amis`. The git fetch runs while the ticket is
  being filed.
- **ARC: Worktree for my open ticket** lets you select an open ticket
  assigned to you. An existing branch opens without creating a duplicate checkout.
- **ARC: Open worktree** lists ARC branches: open Spaces first, then
  worktrees, local branches, and origin-only branches, newest first. Picking
  one focuses its Space, reopens its worktree, or checks it out.
- **ARC: Close worktree + ticket** (also `Ctrl-Shift-w`, a Herdr popup that
  runs the same action with fzf as the picker) lists ARC checkouts. After you
  confirm, it removes the checkout, deletes the branch if it is merged, marks
  the ticket Done through Claude Code, and closes the Space. It refuses a
  checkout with uncommitted changes. It asks again before deleting git-ignored
  files (other than rebuildable caches such as `.terraform`) or the task's
  `HANDOFF.md`, and before marking the ticket Done while the branch has
  commits on no remote.
- If Jira fails after local checkout removal, run
  `herdr-arc finish ~/source/devops ARC-1234` to retry only the Jira transition.
  It asks for confirmation and does not require recreating the checkout. Close
  the remaining Space after completion; the failure message identifies it.
  A new checkout requires a successful fetch, so a fetch failure must be fixed
  before retrying creation. A ticket filed before that failure can be selected
  through **ARC: Worktree for my open ticket**.
- All Herdr worktrees, ARC or not, live in `~/source/worktrees/<repo>/`
  (`worktrees.directory` in `ai/herdr.nix`).
  A checkout's reviewed `.envrc` can use `source_up` to inherit its parent
  environment under `~/source`. Select the AWS profile/region explicitly per
  task; the shell pickers do not persist a shared global identity. direnv whitelists that root, so no `direnv allow` is
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

## Parallel worktrees without losing context

Use one Git worktree and one Herdr Space per independently edited task. Keep
agent, test, and shell tabs in that Space at the same checkout path. Give each
Space the ticket/branch name, and use the workspace picker (`Ctrl-b`, then `w`)
or `Ctrl-Shift-Up/Down` to resume work without switching branches in place.
`Ctrl-b`, then `Shift-g` creates a generic worktree; `Ctrl-Shift-e` provides the
ARC workflows described above.

Before launching parallel work, record the task, branch, checkout path, owner,
and acceptance command in the task description. Assign non-overlapping files
where possible. Reserve a separate worktree for integration and review, and
merge or cherry-pick reviewed changes there one at a time. Branch refs and the
stash are shared within the repository; each worktree has its own index and
working files. A second task should not edit another task's checkout.

For this repository, dry-build the task checkout explicitly:

```sh
bash home-manager/cli/dotfiles/update -n \
  --system-flake "$PWD/nixos" --home-flake "$PWD/home-manager"
```

Use the 2022 hostname explicitly when reviewing that machine:

```sh
nixos-rebuild dry-build --flake ./nixos#lg-gram-14-2022
```

Dry builds plan dependencies; compile/package checks are still needed for
changes that affect build behavior. Each checkout's new files must be tracked
before a Git-backed flake includes them. Keep flake input refreshes with one
owner to avoid conflicting lockfile edits.

For app repositories, share immutable dependency/download caches while keeping
build outputs, local environment overrides, databases, and server ports separate.
Start with two active agents and increase only while the UI stays responsive
and memory pressure/build queues remain acceptable. Use `btop` and
`cat /proc/pressure/memory /proc/pressure/io` to compare before/after behavior;
CPU utilization alone does not show memory or disk contention. Reduce concurrent
heavy builds if task switching degrades or sustained pressure rises. The 8 GiB
laptop has less room for parallel builds than the 2025 machine.

Initialize a handoff inside the task worktree's Git metadata (after activating
the Home Manager template):

```sh
handoff="$(git rev-parse --git-path HANDOFF.md)"
test -e "$handoff" || cp ~/.config/herdr/worktree-handoff.md "$handoff"
```

Before activation, copy `home-manager/ai/dotfiles/worktree-handoff.md` from this
checkout instead. Edit the handoff in place as a current snapshot. Include the
owner, base/current commit, acceptance checks, Space/tab IDs, files owned, ports,
and running commands. This file belongs to one worktree and is not committed.

At handoff, record the exact commit, test result, next step, and any running
service/port. Before removing a checkout, check both uncommitted files and
whether commits are pushed or integrated. ARC close retains an unmerged branch,
but a clean worktree alone is not evidence that its commits are integrated.

The worktree root is automatically trusted by direnv. Review `.envrc` and mise
configuration before bringing an untrusted branch into that root; separate
checkouts isolate files, not credentials or execution privileges. See the
[Git worktree manual](https://git-scm.com/docs/git-worktree) for shared state and
worktree lifecycle details.

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

The daemon starts on demand. Paperclip also requires an explicit start.
OpenRig stores local state in `~/.openrig/`. Use the dashboard to configure and
launch teams. Review the setup preview before applying `rig setup`, which can
change agent trust settings. Update the `openrig` flake input, dependency lock,
and package hash to upgrade through Home Manager.

## Paperclip

Start Paperclip explicitly with `systemctl --user start paperclipai`, then open
<http://127.0.0.1:3100> to create a company, add agents, and assign work.
The dashboard listens on loopback and is not attached to the login target.
Once started, it stays running until stopped or the user manager exits;
lingering can keep an explicitly started service alive after logout.

| Command | Purpose |
| --- | --- |
| `systemctl --user start paperclipai` | Start the dashboard when needed |
| `systemctl --user stop paperclipai` | Stop it when finished |
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
the tunnel unit to exit without retrying; provision its token and start it
explicitly when ready. Tunnel/DNS/Access infrastructure is managed
outside this repository in `~/source/personal/terraform/core/`.

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

### Cloud identity in parallel tasks

`ap` and `ar` select the AWS profile and region for the invoking shell and its
children. They do not write shared identity files or change other running tabs.
For reproducible task environments, declare `AWS_PROFILE`, `AWS_REGION`, and a
separate writable `KUBECONFIG` in that worktree's reviewed direnv configuration.
Do not copy credential contents into the checkout or handoff document.
`rst` returns to `~/source`, unsets the current kube context through `kubectx`,
and clears `AWS_PROFILE`/`AWS_REGION`. Other shells can share that kubeconfig;
use a task-specific `KUBECONFIG` when context isolation matters. Inspect the
resulting directory environment before running a mutating cloud command.

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

On AC power, GNOME locks/blanks after 15 minutes and automatically suspends
after two hours of idle time (`7200` seconds). Battery suspend uses its own
policy. A lock does not keep a long-running job awake through suspend.

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
with a dry build of the checkout being reviewed. A switch activates changes and
is a separate operation. Interactive switching belongs in a Herdr tab because it
may be long-running and can involve prompts.
