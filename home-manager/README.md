# home-manager

User flake. See the root README for daily use.

## First install (after the system is up)

```sh
# 1. Clone repo into your source dir
mkdir -p ~/source/personal && cd ~/source/personal
git clone git@github.com:NelsonJeppesen/nix-lifestyle.git

# 2. Link the flake to where home-manager looks
mkdir -p ~/.config
ln -s ~/source/personal/nix-lifestyle/home-manager ~/.config/home-manager

# 3. Build the activation package using this flake's locked Home Manager input
activation=$(nix --extra-experimental-features 'nix-command flakes' build \
  --no-link --print-out-paths \
  ~/.config/home-manager#homeConfigurations.nelson.activationPackage)
"$activation/activate"
```

## Rebuild

```sh
home-manager switch --flake ~/.config/home-manager#nelson
```

Before activation, restore the user's age decryption identity and the encrypted
files under `/etc/secrets/encrypted/`. Do not place private keys in the checkout.
The account, home path, and supported architecture are declared in `other.nix`
and `flake.nix`; adapt those if installing for someone other than `nelson`.

Eval is pure (no `--impure`); `age.secrets.<name>.file` entries are quoted strings so the encrypted files are referenced at runtime, not copied into the store at eval time.

`update` switches NixOS with `nixos-rebuild`, then Home Manager with `nh`.
Use `update -u` to refresh both lock files first. Run `firmware-update`
separately because it needs interactive sudo.

`update -n` evaluates both build plans without activation or lock updates. For a
worktree, pass `--system-flake "$PWD/nixos" --home-flake "$PWD/home-manager"`
from its root. Input refreshes require user-writable checkouts and run as that
user; only system activation uses sudo.

For a review without activation, run from the repository root:

```sh
nix build --dry-run --no-link --no-update-lock-file \
  ./home-manager#homeConfigurations.nelson.activationPackage
```

A dry build checks evaluation and reports build work; it does not compile every
pending derivation or exercise application behavior. New source files must be
visible to Git before a Git-backed flake includes them.
