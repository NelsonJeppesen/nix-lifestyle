# AGENTS.md – home-manager/ (user layer)

Flake-based. Single output: `homeConfigurations."nelson"` for `x86_64-linux`. Inputs: `nixpkgs` (unstable), `home-manager`, `agenix`, `gitalias` (non-flake), `gnome-github-notifications-redux`. Inputs are plumbed to modules via `extraSpecialArgs`.

## STRUCTURE
- `flake.nix` / `flake.lock` – inputs + single user output
- `home.nix` – top-level module: imports all feature modules, defines `age.secrets`, `home.packages`, dotfile symlinks
- `<feature>.nix` – one concern per file (`neovim`, `zsh`, `kitty`, `firefox`, `chrome`, `chrome-apps`, `git`, `gnome`, `gnome-extensions`, `mcp`, `opencode`, `editorconfig`)
- `dotfiles/` – static files symlinked into `$HOME` via `home.file."<path>".source = ./dotfiles/<file>`
- `bin/` – user scripts (`nsr`, `rgreplace`); package via `home.packages` or symlink, not via `home.file`

## BUILD
```
home-manager switch --flake ~/.config/home-manager#nelson
```
`age.secrets.<name>.file` MUST be a quoted string (`"/etc/secrets/encrypted/<name>.age"`); a bare path literal copies the file into the store at eval time and breaks pure-eval, forcing `--impure`.

The `update` script (in `dotfiles/`, symlinked to `~/.local/bin/update`) switches both layers sequentially via `nh` (system first via `nh os switch /etc/nixos`, then user via `nh home switch ~/.config/home-manager -c nelson`); sequential keeps nh's TUI/diff output legible. Default = switch from current `flake.lock`; firmware fires randomly ~1% of invocations. Flags: `-u` refresh flake inputs (both layers in parallel), `-f` force firmware this run, `-F` skip the firmware roll, `-a` = `-u -f`, `-h` help. `nh` itself comes from `pkgs.nh` in `home.packages`.

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
- Putting executables in `dotfiles/` and using `home.file` instead of `home.packages` for installable binaries
