# Nix Lifestyle

A personal, reproducible NixOS + Home Manager setup for laptops, dev workstations, and a tiny k3s cluster of old MacBooks. It aims to be:

- Declarative & auditable (system + user config in one repo)
- Fast to bootstrap (few manual steps; scripted disk + secrets layout)
- Battery‑aware (TLP tuning, GPU / VAAPI config, Firefox & Chrome flags)
- Quiet & distraction‑reduced (trimmed GNOME, curated extensions, subdued notifications)
- Comfortable for daily development (Neovim-first, powerful shell, Git ergonomics)

> NOTE: This is intentionally opinionated and optimized for my hardware + habits. Steal ideas freely, but expect to adapt paths, usernames, and secrets handling.

---
## Table of Contents
1. Quick Start (Fresh Install)
2. Repository Layout
3. Machines & Host Selection
4. System Profiles (NixOS)
5. Home Manager Configuration
6. Secrets (agenix / age)
7. Notable Tweaks & Opinions
8. Daily Usage Cheatsheet
9. Updating / Rebuilding
10. Extending (Add a Machine / Package)
11. Future / Ideas

---
## 1. Quick Start (Fresh Install)
High‑level flow: boot → network → enable channels → partition+format (disko) → copy repo → link → install.

Boot a current NixOS ISO and become root if needed.

```bash
# 1. (Optional) faster keyboard + fetch tools
loadkeys us

# 2. Networking (Wi‑Fi example)
iwctl station wlan0 connect <SSID>

# 3. Channels (unstable + agenix)
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --add https://github.com/ryantm/agenix/archive/main.tar.gz agenix
nix-channel --update

# 4. Partition + format disks using disko profile
nix run \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes \
  github:nix-community/disko -- \
  --mode disko ./nixos/profiles/x86_64.nix

# 5. Mount (disko profile already mounted / if not ensure /mnt is ready)
# (verify: ls /mnt)

# 6. Bring in this repo + secrets (read only public parts still work)
cd /etc
# secrets are private; clone will fail without access – skip if you don't have them
git clone git@github.com:NelsonJeppesen/secrets.git || true
cd /mnt
cp -r /path/to/checkout/nix-lifestyle .
mkdir -p /mnt/etc
cd /mnt/etc
ln -s ../nix-lifestyle/nixos .

# 7. Define host name expected by configuration.nix
echo lg-gram-pro-17-2025 > /mnt/etc/nixos/.hostname  # pick one in nixos/machines

# 8. Install
nixos-install --upgrade
```

After first boot: enable Home Manager (see section 5) to pull in the user environment.

---
## 2. Repository Layout
```
.
├── home-manager/         # User environment (programs, dotfiles, GUI & shell config)
│   ├── home.nix
│   ├── *.nix             # Feature-specific splits (neovim, zsh, firefox, kitty, git...)
│   └── dotfiles/         # Tracked artifacts symlinked into $HOME
├── nixos/                # System layer
│   ├── configuration.nix # Entry point (imports hostname + core profiles)
│   ├── machines/         # Per-host hardware/personality modules
│   ├── profiles/         # Reusable bundles: gnome, intel, desktop, networking, k3s, factorio...
│   └── overlays/         # Package overrides / additions
├── .github/workflows/    # CI / tag automation (if extended later)
└── README.md
```

---
## 3. Machines & Host Selection
Each machine file under `nixos/machines/` imports a curated set of profiles. Current examples:

- `lg-gram-14-2022.nix`
- `lg-gram-17-2022.nix`
- `lg-gram-pro-17-2025.nix` (modern Intel Xe + forced xe driver probing)
- `macbook12-{0,1,2}.nix` (repurposed as lightweight k3s servers)

Selection is dynamic: `configuration.nix` reads `/etc/nixos/.hostname`. To switch hosts on an existing install:
```bash
echo lg-gram-pro-17-2025 | sudo tee /etc/nixos/.hostname
sudo nixos-rebuild switch
```

---
## 4. System Profiles (NixOS)
Key profiles under `nixos/profiles/`:

- `shared.nix` – Common defaults: zsh system shell, neovim default editor, Wayland env vars, GC policy, fwupd, zram, experimental features `nix-command flakes` enabled (repo itself still channel-based)
- `intel.nix` – Modern Intel iGPU stack (libva/iHD, VAAPI bridges), Wayland prefs, TLP & thermald power tuning, kernel modules for encrypted disk performance
- `desktop.nix` – Bluetooth, PipeWire (Pulse replacement), quiet boot parameters, systemd-boot limits & plymouth
- `gnome.nix` – Strips unused GNOME components; custom XKB layout
- `networking.nix` – Firewall openings (KDE Connect, Spotify Connect), NetworkManager VPN plugins, systemd-networkd baseline
- `k3s.nix` – Lightweight Kubernetes (server role) with token from age secret
- `factorio.nix` – Example of overlaying a package requiring authentication (Factorio) using age secrets
- `x86_64.nix` – Disk layout via disko (GPT, LUKS, btrfs w/ discard & autodefrag) + podman with dockerCompat
- `s3fs.nix`, `software_defined_radio.nix` – Optional capabilities (mounting / SDR tooling)
- `agenix.nix` – Wires in agenix module + agenix CLI

Overlays live in `nixos/overlays/` for custom or pinned packages.

---
## 5. Home Manager Configuration
Bootstrap (user shell after system boot):
```bash
# Clone repository somewhere (example path used in configs)
mkdir -p ~/source/personal
cd ~/source/personal
git clone git@github.com:NelsonJeppesen/nix-lifestyle.git

# Link to Home Manager expected location
mkdir -p ~/.config
ln -s ~/source/personal/nix-lifestyle/home-manager ~/.config/home-manager

# Channel-based install (matches current approach)
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install

# Activate
home-manager switch
```

`home-manager/home.nix` imports feature modules:
- `neovim.nix` – Extensive plugin list (Treesitter all grammars, snacks.nvim, blink.cmp + copilot + avante, diagnostics glyphs, LSP enable calls, keybinding discovery with which-key) + movement discipline (disabled arrow keys) & editing QoL
- `zsh.nix` – Atuin (self-hostable history sync), fzf, direnv, starship prompt with right‑side kube context, a pile of shell aliases and helper functions (AWS profile switcher, base64 tools, Terraform state helpers)
- `kitty.nix` – Theming auto-switch, keybindings for AI chat sessions, scratch editing of captured terminal output, fonts normalized to GNOME
- `firefox.nix` – Performance flags for Wayland + background throttling, custom search engines (gmail, nix packages, AI models), UI chrome minimization
- `chrome-apps.nix` – Minimal battery-conscious PWA wrappers for Slack & ChatGPT with tuned flags
- `git.nix` – Global includes for massive alias set (gitalias), SSH signing by default, difftastic integration, fuzzy branch checkout alias
- `gnome*.nix` – Declarative dconf settings, accent color, keybinding remaps, clipboard & lofi radio extensions, Just Perfection cleanup, run-or-raise shortcuts
- `editorconfig.nix` – Shared formatting defaults (2-space indent, UTF-8, LF, trim)

Secrets (injected by agenix home module) place files like `.aws/credentials`, `.envrc`, and kubeconfig into the expected project tree.

---
## 6. Secrets (agenix / age)
Secrets are not stored in this repository. They are expected under `/etc/secrets/encrypted/*.age` (mounted/managed separately) and mapped via `age.secrets` in both system and home modules.

Examples:
- k3s token (`k3s-token.age`)
- AWS credentials & profiles
- Factorio auth token (optional)
- direnv environment files

To add a new secret:
1. Place encrypted file at `/etc/secrets/encrypted/<name>.age`
2. Add an entry to the appropriate `age.secrets` attrset (system or home)
3. Rebuild (`nixos-rebuild switch` or `home-manager switch`)

---
## 7. Notable Tweaks & Opinions
- Wayland-first: environment variables bias toolkits toward Wayland; fallback still allowed
- TLP profile tuned for quiet thermals & battery (caps Turbo, sets powersave governors)
- Firefox/Chrome: aggressive background throttling and low refresh behavior for idle savings
- GNOME: CapsLock remapped to Super; custom media + volume chord mappings; super+space repurposed
- Kitty: Large scrollback, symbol map for Nerd Font glyphs without patched base font; curated layouts
- Neovim: Intentionally discourages arrow keys; rich structural motion via Treesitter textobjects; quick LSP symbol pickers via Snacks
- Shell: Atuin full-text search, fuzzy AWS profile + region choosers, terraform state manipulation helpers, starship right prompt kube context
- Git: Always signed commits (SSH), difftastic for semantic diffs, date-sorted branches by default
- AI Workflow: `aichat` pre-wired with kitty function keys launching different model sessions

---
## 8. Daily Usage Cheatsheet
| Action | Command / Keys |
|--------|----------------|
| Rebuild system | `sudo nixos-rebuild switch` |
| Update HM env  | `home-manager switch` |
| Launch AI (fast) | Kitty `F1` |
| Launch AI (o1 preview) | Kitty `F2` |
| Global grep (nvim) | `<leader>/` via Snacks picker |
| Open Oil file explorer | `<leader>e` |
| Toggle Precognition hints | `<leader>q` / `q` peek |
| Copy buffer to clipboard | `<leader>uc` |
| Terraform plan (alias) | `tp` |
| AWS profile picker | `ap` (fzf) |
| AWS region picker | `ar` |
| Reset env baseline | `rst` |

---
## 9. Updating / Rebuilding
```bash
# Pull latest config
git -C ~/source/personal/nix-lifestyle pull

# System layer
sudo nixos-rebuild switch

# Home layer (idempotent; safe to run often)
home-manager switch
```
Package / channel updates come from the configured channels (unstable + home-manager master). Garbage collection runs weekly (30d retention) via `shared.nix`.

If migrating to flakes in the future, the `experimental-features` flag is already set—only a `flake.nix` + `flake.lock` scaffold is needed.

---
## 10. Extending
Add a new machine:
```bash
cp nixos/machines/lg-gram-pro-17-2025.nix nixos/machines/my-host.nix
# Edit imports / driver quirks
echo my-host | sudo tee /etc/nixos/.hostname
sudo nixos-rebuild switch
```

Add a user GUI package (Home Manager): edit `home-manager/home.nix` and append to `home.packages` (or better: split a new module and import it).

Add a system service: place a new module in `nixos/profiles/` and import it from the machine file (or from `configuration.nix` if global).

Add a secret-backed authenticated package: follow the `factorio.nix` overlay pattern—read decrypted secret via `builtins.readFile config.age.secrets.<name>.path`.

---
## 11. Future / Ideas
- Introduce full flake workflow (inputs pinning + devShells)
- Binary cache (attic or cachix) for faster multi-host rebuilds
- Automated CI lint (nixfmt, dead code detection) before tagging
- Module consolidation for per-role presets ("workstation", "lab", "server")
- Declarative container workloads (podman quadlet units)

---
## FAQ
**Why channels instead of flakes?** Pragmatic continuity; flakes can be added without reworking semantics later.

**Why age/agenix instead of sops-nix?** Minimal surface + straightforward integration; fits small secrets set.

**Can I reuse this?** Yes—treat it as reference. Remove personal paths (`/home/nelson`) and secrets assumptions first.

---
## Non-Goals
- Turnkey multi-user platform abstraction
- Supporting non-NixOS distros (this is NixOS + Home Manager only)
- Shipping universally sensible defaults (entirely personal bias here)

---
## Closing
This repo is a living notebook of how I like my environment tuned. If you adapt it, keep the declarative clarity—prefer a new module over inline sprawl, and document choices near the code.

Happy hacking.
