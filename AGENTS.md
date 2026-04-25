# AGENTS.md – Nix Lifestyle Repo Guidance

Personal NixOS + Home Manager monorepo. Both layers are flakes (separate, not unified). Two AGENTS.md children carry the layer-specific rules.

## LAYOUT (only what's non-obvious)
- `nixos/`        – system layer; flake at `nixos/flake.nix`; one `nixosConfigurations.<hostname>` output per file in `nixos/machines/`
- `home-manager/` – user layer; flake at `home-manager/flake.nix`; single `homeConfigurations."nelson"` output
- No top-level `flake.nix`; the two flakes are intentionally independent (each pins its own `nixpkgs`)
- No `nixos/overlays/` directory; package overrides live inline in profiles via `overrideAttrs`

See `nixos/AGENTS.md` and `home-manager/AGENTS.md` for layer-specific rules.

## BUILD
- System: `sudo nixos-rebuild switch --flake /etc/nixos` (`/etc/nixos` symlinks to `nixos/`; hostname inferred from `$HOSTNAME` if `#name` omitted); dry: append `--dry-run`
- Home:   `home-manager switch --flake ~/.config/home-manager#nelson`
- `age.secrets.<x>.file` MUST be a string (`"/etc/secrets/encrypted/<x>.age"`), never an unquoted path literal — string form keeps eval pure (no copy into store), so `--impure` is not required
- Convenience wrapper: `~/.local/bin/update` (symlinked from `home-manager/dotfiles/update`) switches both layers sequentially via `nh` (system first, then home; sequential keeps nh's TUI legible — nh handles sudo). Default = switch from current `flake.lock`; firmware fires randomly ~1% of invocations. Flags: `-u` refresh flake inputs (both layers in parallel) before switching; `-f` force firmware this run; `-F` skip the firmware roll; `-a` = `-u -f`; `-h` help
- "Test" = successful dry build with no activation; no other test suite exists

## CONVENTIONS (deviations from generic Nix style)
- Files: hyphen-case (`macbook12-0.nix`, `lg-gram-pro-17-2025.nix`); attrs: snake_case
- Module body order: enable flags + package lists first, then large blobs (Lua, `extraConfig`) last
- Imports order: builtins/pkgs → local `profiles/`/`machines/` → flake inputs via `specialArgs`
- External deps: add as a flake input and pass through `specialArgs` (see `nixos/flake.nix` `mkSystem` for `agenix` + `disko`); do NOT introduce new `builtins.fetchGit`/`fetchTarball` calls
- Package patches: prefer `pkgs.<name>.overrideAttrs` + `postPatch` + `substituteInPlace --replace-fail` (see `nixos/profiles/desktop.nix` plymouth polaroid)
- EditorConfig: 2-space indent, UTF-8, LF, trim trailing whitespace, final newline (enforced by `home-manager/editorconfig.nix`)

## FORMAT BEFORE COMMIT
- Nix: `nixfmt` (RFC style) on touched `*.nix` only — never bulk-reformat
- Shell: `shfmt -i 2 -s` on touched scripts; keep POSIX-safe; quote vars
- Skip if file unchanged. Do not auto-upgrade style across repo without explicit functional change approval.

## ANTI-PATTERNS (this repo)
- Introducing a top-level `flake.nix` or merging the two layers into one — they are intentionally separate
- Reintroducing channel-style references (`<nixpkgs>`, `<agenix>`, `nix-channel --add`) — flakes are the sole input source
- Using `throw` for control flow — prefer conditional attrs / option flags / `lib.mkIf`
- Committing decrypted secrets — only `age.secrets` references; encrypted files live under `/etc/secrets/encrypted/` (separate repo, not here)
- Inflating an existing unrelated module — split a new module instead
- Bulk reformatting alongside a functional change in separate commits — keep formatting + functional change in one commit if both touch the same file
- Adding redundant linters/formatters — Neovim config already provides LSP + formatters

## GIT
- SSH-signed commits required; messages: imperative, why > what, ≤72 char subject
- Large refactors: propose plan first, then ship functional + formatting in one commit
- No Cursor/Copilot rule files; this AGENTS.md governs all agent behavior
