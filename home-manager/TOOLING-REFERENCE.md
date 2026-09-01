# Home Manager Tooling Reference

This is the practical reference for the Git, pull-request, OpenCode, Pi,
Herdr, Neovim, Serena, Ansible, and supporting shell tooling added or changed
between 2026-07-19 and 2026-08-01.

The current configuration is authoritative. The history section explains why
the tools exist and what they replaced. More focused references remain in:

- `docs/neovim-cheatsheet.md`
- `docs/serena-ansible.md`
- `dotfiles/herdr-usage.txt`
- `AGENTS.md`

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
| Open an agent in a new Herdr tab | `Ctrl-Shift-o` for OpenCode, `Ctrl-Shift-p` for Pi |
| Navigate to a known project | `z NAME` or `cd ~NAME` |
| Search source structurally | `ast-grep` |
| Find which Nix package supplies a command | `nix-locate bin/COMMAND` |
| Temporarily run an uninstalled command | `, COMMAND` |
| Inspect symbol relationships across a repository | Ask OpenCode to use Serena |
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

There are no custom agent definitions in `opencode.nix`. Pi is a separate
coding agent, and Serena is an MCP server.

The former `oc-standup` workflow was removed.

### MCP servers

<!-- markdownlint-disable MD013 -->

| Server | OpenCode | Notes |
| --- | ---: | --- |
| Atlassian | Enabled | Interactive OAuth for Jira/Confluence |
| GitHub | Enabled | Uses `GITHUB_TOKEN`; PR, issue, repository, and Actions tools |
| Terraform | Enabled | Registry/provider/module documentation tools |
| Memory | Enabled | Persistent graph at `~/.local/share/mcp-memory/memory.json` |
| Serena | Enabled | Symbol-aware code tools; current-directory project selection |
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

Pi does not currently receive Serena, Kubernetes, or Slack-write. Pi and
OpenCode share the same persistent memory JSON file. Herdr reports Pi's
blocked, working, and done states in the sidebar.

## Serena

Serena provides semantic symbol lookup, declaration/reference traversal, and
symbol-aware edits. Use normal file reads and searches for small one-file work;
use Serena when relationships across files or modules matter.

For an Ansible repository:

```bash
cd /path/to/repository
serena project create --language ansible .
serena project index       # optional for a large repository
```

Example prompts:

```text
Use Serena to get a symbol overview of roles/web/tasks/main.yml, then trace the
handler and variable references involved in restarting nginx. Do not edit yet.
```

```text
Use Serena's symbol and reference tools to find every role affected by renaming
web_service_port. Make the smallest safe edit, then run ansible-lint.
```

OpenCode launches Serena with:

- Project selection from OpenCode's current working directory.
- IDE and editing modes.
- Serena memories disabled because the shared memory MCP is authoritative.
- No web dashboard.
- Trusted projects restricted to `~/source/**`.
- A 240-second tool timeout.
- Nix-managed Ansible language server, Ansible, Python, and ansible-lint.

Serena deliberately excludes duplicate generic file, directory, text search,
replacement, and shell tools. Use OpenCode's native tools for those operations.

Project-local `.serena/` state may be untracked. Review it before deciding
whether it is repository policy or machine-local indexing configuration.

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
| `Ctrl-Shift-t` | New tab |
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
| `Ctrl-Shift-o` | OpenCode tab at active directory |
| `Ctrl-Shift-p` | Pi tab at active directory |
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

It imports `home-manager/opencode.nix`, but not the separate `serena.nix`,
`pi.nix`, `herdr.nix`, or `git.nix` modules. Therefore it does not
automatically receive Serena or Pi even though its core
OpenCode settings and inline MCP configuration match.

## Neovim

`vim` invokes Neovim. `MANPAGER` also uses `nvim +Man!`.

### LSP and linting

The main LSP servers include:

- `ansiblels`
- `bashls`
- `jinja_lsp`
- `jsonls`
- `nixd`
- `ruby_lsp`
- `terraformls`
- `typos_lsp`
- `yamlls`

The enabled-server line in `docs/neovim-cheatsheet.md` currently omits
`ansiblels` and `jinja_lsp`; the configuration in `neovim.nix` is
authoritative.

Save-time `nvim-lint` mappings:

| Filetype | Linter |
| --- | --- |
| `yaml.ansible` | `ansible-lint` |
| `yaml.ghaction` | `actionlint` |
| `dockerfile` | `hadolint` |
| `markdown` | `markdownlint` |
| `sh` | `shellcheck` |
| `terraform` | `tflint` |
| `yaml` | `yamllint` |

Lint runs after a successful write. It does not explicitly run when a file is
opened; save the file or press `<leader>ll`. Findings flow into ordinary
Neovim diagnostics and Trouble alongside LSP diagnostics.

Useful keys:

| Key | Action |
| --- | --- |
| `<leader>ll` | Lint current buffer |
| `<leader>lf` | Format through conform.nvim with LSP fallback |
| `<leader>xx` | Workspace diagnostics |
| `<leader>xX` | Current-buffer diagnostics |
| `<leader>ln` / `<leader>lp` | Next/previous diagnostic |
| `<leader>li` | LSP information |
| `<leader>la` | Code action |
| `<leader>lR` | Rename symbol |

Ansible language-server linting is disabled in Neovim because `nvim-lint`
already runs `ansible-lint`; this avoids duplicate diagnostics. Serena has its
own Ansible lint integration for semantic tooling.

### Relevant behavior changes

- `hardtime.nvim` was removed; repeated motions are no longer throttled.
- Arrow keys remain independently disabled.
- Conditional text objects are `aI` / `iI`, leaving lowercase `ai` / `ii` for
  indentation text objects.
- LSP file logging is off.
- F1 scrollback editing belongs to Herdr, not Kitty.

### OpenCode integration

The OpenCode Neovim plugin includes these useful mappings:

| Key | Action |
| --- | --- |
| `<leader>oa` | Ask OpenCode |
| `<leader>ox` | Select an OpenCode action |
| `<leader>op{motion}` | Add a range to the prompt/context |
| `<leader>og` | Add a diagnostic/context item |

See `neovim.nix` and `docs/neovim-cheatsheet.md` for the full current mapping
set.

## Ansible Toolchain

Installed commands include:

- `ansible`
- `ansible-builder`
- `ansible-lint`
- `ansible-navigator`
- `molecule`
- `ansible-language-server`

Common checks and workflows:

```bash
ansible-playbook --syntax-check playbook.yml
ansible-lint
molecule test
ansible-navigator run playbook.yml
ansible-builder build
```

Use `ansible-navigator` for the interactive execution UI and
`ansible-builder` when a project defines an execution environment. Serena and
Neovim improve navigation and feedback but do not replace syntax checks,
ansible-lint, or Molecule.

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

### Serena has no project or wrong language

```bash
serena project create --language LANGUAGE .
```

Review `.serena/project.yml`, then fully restart OpenCode if the MCP server was
newly added or its global settings changed. Use `serena project index` only
when pre-caching a large repository is useful.

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
comment in `gnome.nix` currently says three hours, but `7200` seconds and the
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
| 2026-08-01 | `8e694a7` | Updated flake pins and added Serena, nix-index-database, Pi MCP adapter, and a terminal review input. |
| 2026-08-01 | `26f6d42` | Added the Ansible suite, ast-grep, and prebuilt nix-index integration. |
| 2026-08-01 | `8fb22c9` | Added Serena, Pi, gh-dash integration, modern agent tool guidance, and removed `oc-standup`. |
| 2026-08-01 | `4b79708` | Added Ansible/Jinja LSP support and save-time nvim-lint; removed hardtime.nvim. |
| 2026-08-01 | `4d3e9ea` | Added zoxide, bat, named directories, `vu`/`vm`, and the Pi Herdr launcher. |
| 2026-08-01 | `07050ad` | Imported the new feature modules and pruned unused packages. |
| 2026-08-01 | `17093fe` | Added Chromium v11 cookie decryption and padding validation to `slack-stealth-tokens`. |
| 2026-08-01 | `e3ea3e2` | Delayed AC suspend so long-running OpenCode work survives idle lock. |

<!-- markdownlint-enable MD013 -->

### Superseded tools and workflows

- The Git-level `git wt` lazyworktree alias was removed. A shell `wt` function
  may still be available from the separately sourced lazyworktree package.
- `oc-standup` and its redaction/collector files were removed. GitHub work now
  centers on `gh-dash`.
- `hardtime.nvim` was removed.

## Configuration Map

<!-- markdownlint-disable MD013 -->

| Area | Main files |
| --- | --- |
| Git | `git.nix` |
| GitHub dashboard | `gh-dash.nix` |
| OpenCode and MCP servers | `opencode.nix` |
| Pi and its MCP adapter | `pi.nix` |
| Serena | `serena.nix`, `docs/serena-ansible.md` |
| Herdr | `herdr.nix`, `dotfiles/herdr-usage.txt`, `dotfiles/herdr-skill.md` |
| Neovim | `neovim.nix`, `neovim/lua/which-key-nvim.lua`, `docs/neovim-cheatsheet.md` |
| Ansible CLI | `ansible.nix` |
| zoxide and shell helpers | `zoxide.nix`, `zsh.nix`, `dotfiles/zsh-named-dirs.zsh` |
| bat | `bat.nix` |
| ast-grep | `development-tools.nix` |
| nix-index and comma | `nix-index.nix` |
| Feature imports and packages | `home.nix` |
| Input pins and special arguments | `flake.nix`, `flake.lock` |

<!-- markdownlint-enable MD013 -->

After changing these modules, format touched Nix files with `nixfmt` and test
with a Home Manager build/switch appropriate to the task. Interactive switching
belongs in a Herdr tab because it may be long-running and can involve prompts.
