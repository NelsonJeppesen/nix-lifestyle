# AGENTS.md – home-manager/ (user layer)

Flake-based. Single output: `homeConfigurations."nelson"` for `x86_64-linux`.

## STRUCTURE
- `flake.nix` / `flake.lock` – inputs + single user output
- `home.nix` – imports category modules and `other.nix`
- `gnome/`, `cli/`, `neovim/`, `gui/`, `ai/` – feature modules, packages, and assets; each has `default.nix`
- `other.nix` – identity, XDG directories, shared secrets, fonts, and EditorConfig
- `<category>/dotfiles/` – static files symlinked into `$HOME`
- `<category>/bin/` – packaged scripts
- `doc/` – Markdown documentation and agent instructions

## BUILD
```
home-manager switch --flake ~/.config/home-manager#nelson
```
`age.secrets.<name>.file` MUST be a quoted string (`"/etc/secrets/encrypted/<name>.age"`); a bare path literal copies the file into the store at eval time and breaks pure-eval, forcing `--impure`.

The `update` script (in `cli/dotfiles/`, symlinked to `~/.local/bin/update`) switches both layers sequentially: system via `sudo nixos-rebuild switch --flake /etc/nixos`, user via `nh home switch ~/.config/home-manager -c nelson`. The system layer calls `nixos-rebuild` directly to match the configured sudo rules; those rules are root-equivalent because arbitrary Nix builds/activations can run as root. The user layer uses nh's diff/progress TUI without sudo. Default = switch from current `flake.lock`; use `update -h` for dry-run, alternate-flake, and input-refresh flags. `nh` comes from `pkgs.nh` in `cli/packages.nix`. Run `firmware-update` separately when needed; it uses interactive sudo for `fwupdmgr`.

## WHERE TO LOOK
| Task                          | Location                          |
|-------------------------------|-----------------------------------|
| Add a CLI/GUI package         | `home.packages` in `cli/packages.nix` or `gui/packages.nix`     |
| Add a feature with config     | new `<category>/<feature>.nix` + import in its `default.nix` |
| Add a static dotfile          | drop in `<category>/dotfiles/` + add `home.file."..." .source = ./dotfiles/...` |
| Add an age-backed user secret | append to `age.secrets` in `other.nix` or the feature module; encrypted file under `/etc/secrets/encrypted/<name>.age` |
| Tweak Neovim                  | `neovim/nvf.nix` — explicit nvf options; edit the option in place, no `mkForce` needed. See `doc/neovim-cheatsheet.md` |
| GNOME dconf / extensions      | `gnome/gnome.nix`, `gnome/extensions_<name>.nix` |

## CONVENTIONS (layer-specific)
- Add feature modules under their category and import them from its `default.nix`; keep `home.nix` and every `default.nix` limited to imports.
- Feature module body order: option enables + package lists first, then large blobs (Lua, `extraConfig`, scripts) last
- Comment package-list entries with one-line purpose; commented-out packages are intentional alternatives — leave them
- Follow the root comment policy: explain present intent for unfamiliar readers and keep zero history in comments, except an active bug workaround or bug-related Git pin with its failure and removal condition.
- Dotfile path inside `home.file."<rel>"` mirrors the eventual location under `$HOME`
- New flake inputs: declare in `flake.nix`, list in the `outputs` argument set, expose via `extraSpecialArgs`, then accept as a function arg where used

## ANTI-PATTERNS
- Writing `age.secrets.<name>.file = /etc/secrets/...;` as a bare path literal — pure-eval will reject it; always use a quoted string
- Adding a top-level `flake.nix` to the repo root or merging this flake with `nixos/flake.nix` — they are intentionally separate
- Bumping `home.stateVersion` casually — only with explicit migration intent
- Adding executable dotfiles without `executable = true`
