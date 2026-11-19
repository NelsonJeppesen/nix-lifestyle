# Nix Lifestyle

A personal, reproducible NixOS + Home Manager setup for my LG Gram laptops.

Goals:
- Declarative & auditable (system + user config in one repo)
- Fast to bootstrap (few manual steps; scripted disk + secrets layout)
- Battery-aware (TLP, VAAPI, Firefox/Chrome flags)
- Quiet & distraction-reduced (trimmed GNOME, curated extensions)
- Comfortable for daily development (Neovim-first, powerful shell, signed git)

> Opinionated and tuned for my hardware + habits. Steal ideas freely; expect to adapt paths, usernames, and secrets handling.

---
## Layout

```
.
├── nixos/             # System layer (flake)
│   ├── flake.nix      # nixosConfigurations.<hostname> per machine in machines/
│   ├── configuration.nix
│   ├── machines/      # Per-host module (lg-gram-*)
│   └── profiles/      # Reusable bundles (gnome, intel, desktop, tailscale, ...)
├── home-manager/      # User layer (flake)
│   ├── flake.nix      # homeConfigurations.nelson
│   ├── home.nix
│   ├── cli/, gui/, gnome/, neovim/, ai/ # Feature modules with default.nix imports
│   ├── <category>/dotfiles/ # Static files, including cli/dotfiles/update
│   ├── <category>/bin/     # Packaged helpers
│   └── doc/               # Tooling reference and user-layer guidance
└── AGENTS.md          # Conventions for AI agents (and humans skimming)
```

Both layers are flakes; each independently locks its `nixos-unstable` input.
There is no root flake. Runtime secrets and application state are outside this
repository and need their own backup/recovery procedure.

---
## Quick start (fresh install)

Follow [the system installation procedure](nixos/README.md), which verifies the
physical disk, uses the locked Disko input, and stages secrets in the installed
root. Disk formatting is destructive; do not infer the target from an NVMe number.
TPM enrollment requires a verified recovery and boot policy.

Then follow [the user-layer setup](home-manager/README.md).

---
## Daily use

```bash
# Switch NixOS with nixos-rebuild, then Home Manager with nh.
# The configured passwordless Nix commands are root-equivalent privileges.
update                     # -u refresh inputs first, -h help
update -n                  # evaluate both build plans without activation
firmware-update            # separate, interactive sudo

# System only
sudo nixos-rebuild switch --flake /etc/nixos          # hostname inferred from $HOSTNAME
sudo nixos-rebuild switch --flake /etc/nixos#<other>  # explicit host

# User only
home-manager switch --flake ~/.config/home-manager#nelson
```

From a worktree, test that checkout explicitly rather than the links pointing
at the main checkout:

```bash
bash home-manager/cli/dotfiles/update -n \
  --system-flake "$PWD/nixos" --home-flake "$PWD/home-manager"
```

`-n` keeps both lockfiles unchanged and cannot be combined with `-u`. Input
refreshes run as the checkout owner; both flake directories must be writable.

Both layers eval pure (no `--impure`); `age.secrets.<x>.file` entries use quoted strings so the encrypted files at `/etc/secrets/encrypted/` are not copied into the store at eval time.

Garbage collection runs weekly via `nh clean all` (30-day retention, at least 5 generations, user profiles included), set in `nixos/profiles/shared.nix`; the store is also deduplicated weekly. Each laptop schedules a monthly low-priority
Btrfs scrub of its root filesystem on AC power; see the system README for
manual checks when a scheduled run is skipped on battery.

---
## Adding things

| Want to                       | Do                                                           |
|-------------------------------|--------------------------------------------------------------|
| Add a new host                | copy a `nixos/machines/*.nix` → add it to `nixos/flake.nix`'s `nixosConfigurations` |
| Add a system service          | new module in `nixos/profiles/` → import from the host module|
| Add a user CLI/GUI package    | append to `home.packages` in `home-manager/cli/packages.nix` or `gui/packages.nix` |
| Add a user feature with config| new `home-manager/<category>/<feature>.nix` → import from that category's `default.nix` |
| Add an age secret             | encrypt to `/etc/secrets/encrypted/<name>.age`, then add an `age.secrets` entry |

---
## Secrets

Encrypted secrets live outside this repo, under `/etc/secrets/encrypted/*.age`, managed by [agenix](https://github.com/ryantm/agenix). They are referenced (never decrypted) by `age.secrets` in both layers.

Examples currently wired up:
- `awscredentials.personal.age` — AWS credentials
- `kubeconfig.personal.age` — kubeconfig (decrypted to `.orig` for context-switching workflows)
- `envrc.{personal,root}.age` — direnv envs

---
## Notable opinions

- **Wayland-first**: GTK, Firefox and Electron apps (`NIXOS_OZONE_WL`) run on Wayland natively; X11 apps run through XWayland
- **TLP**: powersave governors with AC/battery energy preferences and hardware-specific charge limits
- **Firefox/Chrome/Electron**: explicit media and rendering preferences with default background scheduling and V8 memory management
- **GNOME**: CapsLock → Super (via keyd), heavy dconf/keybinding remap, run-or-raise shortcuts
- **Kitty + herdr**: Kitty renders one window; local Herdr Spaces own task worktrees, tabs, and sessions. Remote/mobile relay provisioning is disabled
- **Kitty + agent-deck**: a second Kitty window (`Super+A`) runs agent-deck, a tmux-backed dashboard of agent sessions
- **Neovim**: nvf (`home-manager/neovim/nvf.nix`) — every plugin and language server is an explicit
  Nix option. No Lua config directory, nothing installs at runtime
- **Shell**: Atuin (self-hostable history sync), fuzzy AWS profile/region pickers, terraform state helpers, kubectx in starship right prompt
- **Git**: SSH-signed commits required, gitalias as a flake input

---
## Cheatsheet

| Action                       | Command / Keys             |
|------------------------------|----------------------------|
| Update everything            | `update`; `update -n` previews both build plans |
| Edit terminal scrollback     | herdr `F1`                 |
| New Claude Code / OpenCode / Codex / shell tab | `Ctrl+Shift+Y` / `O` / `X` / `S` (in herdr) |
| Open agent-deck dashboard    | `Super+A`                  |
| Open herdr-projects popup    | `Ctrl+Shift+A` only when the optional `ai/herdr-projects.nix` module is enabled |
| herdr-plus workspace picker | `Ctrl+Shift+G` (in herdr)  |
| herdr-plus quick actions     | `Ctrl+Shift+E` (in herdr)  |
| New/existing ARC worktree    | `Ctrl+Shift+E` → DevOps: ARC actions |
| Global grep (nvim)           | `<leader>fg` (Telescope)   |
| File explorer (nvim)         | `:Neotree`                |
| Copy buffer to clipboard     | `:%y+`                     |
| Terraform plan               | `tp`                       |
| AWS profile / region picker  | `ap` / `ar`                |
| Reset env baseline           | `rst`                      |

For reviewers, [the tooling reference](home-manager/doc/TOOLING-REFERENCE.md)
maps commands to their source modules. Comments explain current intent and
constraints; Git carries change history. Active bug workarounds retain their
failure and removal conditions.

---
## Non-goals

- Multi-user platform abstraction
- Non-NixOS distros
- Universally sensible defaults — this is personal bias

---

A living notebook of how I like my environment tuned. Adapt freely; keep the declarative clarity (prefer a new module over inline sprawl, document choices near the code).

Happy hacking.
