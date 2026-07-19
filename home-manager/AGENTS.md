# AGENTS.md – home-manager/ (user layer)

Flake-based. Single output: `homeConfigurations."nelson"` for `x86_64-linux`.

## STRUCTURE
- `flake.nix` / `flake.lock` – inputs + single user output
- `home.nix` – top-level module: imports all feature modules, defines `age.secrets`, `home.packages`, dotfile symlinks
- `<feature>.nix` – one concern per file; imports live in `home.nix`
- `dotfiles/` – static files symlinked into `$HOME` via `home.file."<path>".source = ./dotfiles/<file>`
- `bin/` – scripts packaged with `writeShellApplication`

## BUILD
```
home-manager switch --flake ~/.config/home-manager#nelson
```
`age.secrets.<name>.file` MUST be a quoted string (`"/etc/secrets/encrypted/<name>.age"`); a bare path literal copies the file into the store at eval time and breaks pure-eval, forcing `--impure`.

The `update` script (in `dotfiles/`, symlinked to `~/.local/bin/update`) switches both layers sequentially: system via `sudo nixos-rebuild switch --flake /etc/nixos`, user via `nh home switch ~/.config/home-manager -c nelson`. nh is deliberately NOT used for the system layer — nh always wraps activation in `sudo env … switch-to-configuration`, which can't be safely scoped in sudoers (allowing `sudo env` is equivalent to full root). Calling `nixos-rebuild` directly lets the narrow allowlist in `nixos/profiles/shared.nix` (just `nixos-rebuild` + `nix`) actually work. nh is still used for the user layer because that needs no sudo, and we keep its diff/progress TUI there. Default = switch from current `flake.lock`. Flags: `-u` refresh flake inputs (both layers in parallel), `-h` help. `nh` itself comes from `pkgs.nh` in `home.packages`. Firmware updates are NOT part of `update`: run `firmware-update` (also in `dotfiles/`, symlinked to `~/.local/bin/firmware-update`) manually when needed — it uses interactive sudo for `fwupdmgr`.

## WHERE TO LOOK
| Task                          | Location                          |
|-------------------------------|-----------------------------------|
| Add a CLI/GUI package         | `home.packages` in `home.nix`     |
| Add a feature with config     | new `<feature>.nix` + import in `home.nix` |
| Add a static dotfile          | drop in `dotfiles/` + add `home.file."..." .source = ./dotfiles/...` |
| Add an age-backed user secret | append to `age.secrets` in `home.nix`; encrypted file under `/etc/secrets/encrypted/<name>.age` |
| Tweak Neovim                  | `neovim.nix` (large Lua blob at bottom — module-body convention applies) |
| GNOME dconf / extensions      | `gnome.nix`, `gnome-extensions.nix` |

## CONVENTIONS (layer-specific)
- Always extend by adding a new `<feature>.nix` and importing it from `home.nix`; do not inline new feature config into `home.nix`
- Feature module body order: option enables + package lists first, then large blobs (Lua, `extraConfig`, scripts) last
- Comment package-list entries with one-line purpose; commented-out packages are intentional alternatives — leave them
- Dotfile path inside `home.file."<rel>"` mirrors the eventual location under `$HOME`
- New flake inputs: declare in `flake.nix`, list in the `outputs` argument set, expose via `extraSpecialArgs`, then accept as a function arg where used

## ANTI-PATTERNS
- Writing `age.secrets.<name>.file = /etc/secrets/...;` as a bare path literal — pure-eval will reject it; always use a quoted string
- Adding a top-level `flake.nix` to the repo root or merging this flake with `nixos/flake.nix` — they are intentionally separate
- Bumping `home.stateVersion` casually — only with explicit migration intent
- Adding executable dotfiles without `executable = true`
