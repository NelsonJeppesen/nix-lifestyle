# home-manager
```bash
# Clone repo into source dir
mkdir -p ~/s
cd ~/s
git clone git@github.com:NelsonJeppesen/nix-lifestyle.git

mkdir -p ~/.config
ln -s ~/s/nix-lifestyle/home-manager ~/.config/home-manager

# Enable flakes (if not already enabled)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Initial installation
cd ~/.config/home-manager
nix run home-manager/master -- init --switch

# Or build and switch manually (requires --impure for agenix secrets)
home-manager switch --flake ~/.config/home-manager#nelson --impure
```

## Updating

The `update` script (symlinked to `~/.local/bin/update`) handles all updates.
It always fetches the latest flake inputs, ignoring the lock file.

Note: `--impure` is required because agenix secrets reference absolute paths in `/etc`.

