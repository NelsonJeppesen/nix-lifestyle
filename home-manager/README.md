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
  run home-manager/master -- init --switch ~/.config/home-manager#nelson --impure
```

## Rebuild

```sh
home-manager switch --flake ~/.config/home-manager#nelson --impure
```

`--impure` is mandatory — `age.secrets` reference absolute paths under `/etc/secrets/encrypted/` which pure-eval rejects.

The `update` script (symlinked to `~/.local/bin/update` from `dotfiles/update`) refreshes flake inputs for both layers and switches.
