# home-manager

User flake. See the root README for daily use.

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

`update` switches NixOS with `nixos-rebuild`, then Home Manager with `nh`.
Use `update -u` to refresh both lock files first. Run `firmware-update`
separately because it needs interactive sudo.
