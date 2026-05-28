# home-manager

User layer (flake). See top-level `README.md` for layout and daily use; this file is bootstrap-only.

## First install (after the system is up)

```sh
# 1. Clone repo into your source dir
mkdir -p ~/s && cd ~/s
git clone git@github.com:NelsonJeppesen/nix-lifestyle.git

# 2. Link the flake to where home-manager looks
mkdir -p ~/.config
ln -s ~/s/nix-lifestyle/home-manager ~/.config/home-manager

# 3. Initial install + switch
nix --extra-experimental-features 'nix-command flakes' \
  run home-manager/master -- init --switch ~/.config/home-manager#nelson
```

## Rebuild

```sh
home-manager switch --flake ~/.config/home-manager#nelson
```

Eval is pure (no `--impure`); `age.secrets.<name>.file` entries are quoted strings so the encrypted files at `/etc/secrets/encrypted/` are referenced at runtime, not copied into the store at eval time.

The `update` script (symlinked to `~/.local/bin/update` from `dotfiles/update`) switches both layers sequentially via `nh` (system first, then user — sequential keeps nh's TUI legible). Default = switch from current `flake.lock`. Pass `-u` to refresh flake inputs (both layers in parallel) first, `-h` for help. Passwordless sudo for `nixos-rebuild`/`nix` is configured in `nixos/profiles/shared.nix`. Firmware updates moved out: run `firmware-update` (also in `dotfiles/`) manually when needed — it uses interactive sudo.
