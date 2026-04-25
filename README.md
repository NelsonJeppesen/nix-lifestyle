# Nix Lifestyle

A personal, reproducible NixOS + Home Manager setup for laptops, dev workstations, and a small k3s cluster of old MacBooks.

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
│   ├── machines/      # Per-host module (lg-gram-*, macbook12-*, openclaw)
│   └── profiles/      # Reusable bundles (gnome, intel, desktop, k3s, ...)
├── home-manager/      # User layer (flake)
│   ├── flake.nix      # homeConfigurations.nelson
│   ├── home.nix
│   ├── *.nix          # neovim, zsh, kitty, firefox, git, gnome, ...
│   ├── dotfiles/      # Static files symlinked into $HOME (incl. `update`)
│   └── bin/           # User scripts (nsr, rgreplace)
└── AGENTS.md          # Conventions for AI agents (and humans skimming)
```

Both layers are flakes; nixpkgs tracks `nixos-unstable`.

---
## Quick start (fresh install)

Boot a current NixOS ISO.

```bash
# 1. Networking
iwctl station wlan0 connect <SSID>

# 2. Partition + format using disko (LUKS + btrfs + EFI)
nix --extra-experimental-features 'nix-command flakes' run \
  github:nix-community/disko -- \
  --mode disko ./nixos/profiles/x86_64.nix

# 3. Bring repo + secrets onto /mnt
cd /etc && git clone git@github.com:NelsonJeppesen/secrets.git || true
sudo cp -r /path/to/checkout/nix-lifestyle /mnt/
sudo mkdir -p /mnt/etc && sudo ln -sf /mnt/nix-lifestyle/nixos /mnt/etc/nixos

# 4. Install for the chosen host (must match a name in nixos/machines/)
sudo nixos-install --flake /mnt/etc/nixos#lg-gram-pro-17-2025

# 5. After boot: enroll TPM2 for automatic LUKS unlock
sudo systemd-cryptenroll /dev/nvme0n1p2 --tpm2-device=auto --tpm2-pcrs=0+7
```

Then bring up the user layer (see `home-manager/README.md`).

---
## Daily use

```bash
# Update everything (firmware → nixos flake → home-manager flake)
update                     # ~/.local/bin/update, see home-manager/dotfiles/update

# System only
sudo nixos-rebuild switch --flake /etc/nixos          # hostname inferred from $HOSTNAME
sudo nixos-rebuild switch --flake /etc/nixos#<other>  # explicit host

# User only
home-manager switch --flake ~/.config/home-manager#nelson --impure
```

`--impure` is required for the home layer because `age.secrets` reference absolute paths under `/etc/secrets/encrypted/`. The same is true for any system rebuild that touches age secrets — the `update` script handles this.

Garbage collection runs weekly (30d retention) via `nixos/profiles/shared.nix`.

---
## Adding things

| Want to                       | Do                                                           |
|-------------------------------|--------------------------------------------------------------|
| Add a new host                | copy a `nixos/machines/*.nix` → add it to `nixos/flake.nix`'s `nixosConfigurations` |
| Add a system service          | new module in `nixos/profiles/` → import from the host module|
| Add a user CLI/GUI package    | append to `home.packages` in `home-manager/home.nix`         |
| Add a user feature with config| new `home-manager/<feature>.nix` → import from `home.nix`    |
| Add an age secret             | encrypt to `/etc/secrets/encrypted/<name>.age`, then add an `age.secrets` entry |

---
## Secrets

Encrypted secrets live outside this repo, under `/etc/secrets/encrypted/*.age`, managed by [agenix](https://github.com/ryantm/agenix). They are referenced (never decrypted) by `age.secrets` in both layers.

Examples currently wired up:
- `k3s-token.age` — k3s cluster token
- `awscredentials.personal.age` — AWS credentials
- `kubeconfig.personal.age` — kubeconfig (decrypted to `.orig` for context-switching workflows)
- `envrc.{personal,root}.age` — direnv envs

---
## Notable opinions

- **Wayland-first**: `GDK_BACKEND=wayland`, X11 fallback allowed
- **TLP**: tuned for quiet thermals + battery (Turbo capped, powersave governors)
- **Firefox/Chrome**: aggressive background throttling for idle savings
- **GNOME**: CapsLock → Super (via keyd), heavy dconf/keybinding remap, run-or-raise shortcuts
- **Kitty**: Nerd Font symbol_map (no patched base font), AI-chat function keys (F1, F2)
- **Neovim**: arrow keys disabled; structural motion via Treesitter textobjects; LSP pickers via Snacks
- **Shell**: Atuin (self-hostable history sync), fuzzy AWS profile/region pickers, terraform state helpers, kubectx in starship right prompt
- **Git**: SSH-signed commits required, difftastic for semantic diffs, gitalias as a flake input

---
## Cheatsheet

| Action                       | Command / Keys             |
|------------------------------|----------------------------|
| Update everything            | `update`                   |
| AI chat (fast model)         | Kitty `F1`                 |
| AI chat (slow model)         | Kitty `F2`                 |
| Global grep (nvim)           | `<leader>/` (Snacks)       |
| File explorer (nvim)         | `<leader>e` (Oil)          |
| Copy buffer to clipboard     | `<leader>uc`               |
| Terraform plan               | `tp`                       |
| AWS profile / region picker  | `ap` / `ar`                |
| Reset env baseline           | `rst`                      |

---
## Non-goals

- Multi-user platform abstraction
- Non-NixOS distros
- Universally sensible defaults — this is personal bias

---

A living notebook of how I like my environment tuned. Adapt freely; keep the declarative clarity (prefer a new module over inline sprawl, document choices near the code).

Happy hacking.
