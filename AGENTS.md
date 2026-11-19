# AGENTS.md – Nix Lifestyle Repo Guidance

Personal NixOS + Home Manager monorepo. Both layers are flakes (separate, not unified). Two AGENTS.md children carry the layer-specific rules.

## LAYOUT (only what's non-obvious)
- `nixos/`        – system layer; flake at `nixos/flake.nix`; one `nixosConfigurations.<hostname>` output per file in `nixos/machines/`
- `home-manager/` – user layer; flake at `home-manager/flake.nix`; single `homeConfigurations."nelson"` output
- No top-level `flake.nix`; the two flakes are intentionally independent (each pins its own `nixpkgs`)
- No `nixos/overlays/` directory; package overrides live inline in profiles via `overrideAttrs`

See `nixos/AGENTS.md` and `home-manager/doc/AGENTS.md` for layer-specific rules.

## BUILD
- System: `sudo nixos-rebuild switch --flake /etc/nixos`; dry: `nixos-rebuild dry-build --flake /etc/nixos`
- Home:   `home-manager switch --flake ~/.config/home-manager#nelson`
- `age.secrets.<x>.file` MUST be a string (`"/etc/secrets/encrypted/<x>.age"`), never an unquoted path literal — string form keeps eval pure (no copy into store), so `--impure` is not required
- Convenience wrapper: `~/.local/bin/update` (symlinked from `home-manager/cli/dotfiles/update`) switches both layers sequentially: system via `sudo nixos-rebuild switch --flake /etc/nixos`, user via `nh home switch`. The passwordless `nix`/`nixos-rebuild` rules in `nixos/profiles/shared.nix` grant root-equivalent capability: allowing arbitrary Nix expressions is not a security boundary. `nh` is used only for the user layer so system activation does not require an additional `sudo env` rule. Default = switch from current `flake.lock`. Use `update -h` for dry-run, alternate-flake, and input-refresh flags. Run `~/.local/bin/firmware-update` (interactive sudo) separately when needed.
- "Test" = successful dry build with no activation; no other test suite exists

## CONVENTIONS (deviations from generic Nix style)
- Files: hyphen-case (`opencode.nix`, `lg-gram-pro-17-2025.nix`); attrs: snake_case
- Module body order: enable flags + package lists first, then large blobs (Lua, `extraConfig`) last
- Imports order: builtins/pkgs → local `profiles/`/`machines/` → flake inputs via `specialArgs`
- External deps: add as a flake input and pass through `specialArgs` (see `nixos/flake.nix` `mkSystem` for `agenix` + `disko`); do NOT introduce new `builtins.fetchGit`/`fetchTarball` calls
- Package patches: prefer `pkgs.<name>.overrideAttrs` + `postPatch` + `substituteInPlace --replace-fail` (see `nixos/profiles/desktop.nix` plymouth polaroid)
- EditorConfig: 2-space indent, UTF-8, LF, trim trailing whitespace, final newline (enforced by `home-manager/other.nix`)

## COMMENTS
- Document each maintained module/script's purpose and the intent, constraints, units, and failure behavior of non-obvious settings so someone other than the owner can review it. Prefer useful section comments to restating every assignment.
- Keep **zero change history in comments**: no dates of changes, previous behavior, migration narratives, "used to", "now", "removed", or author/session notes. Describe the current behavior; Git records how it changed.
- The only exception is an active bug workaround, including a Git revision pin needed to avoid a bug. Explain the affected component/version, failure, and condition for removing the workaround; link the upstream issue or fix when known. Do not invent missing issue numbers or treat ordinary customization as a bug workaround.
- Keep generated lockfiles, machine-readable data, and binary assets in their required formats; explain them in their consuming module or documentation. Historical audit evidence and changelogs are records, not live configuration comments; do not rewrite their snapshots.

## FORMAT BEFORE COMMIT
- Nix: `nixfmt` (RFC style) on touched `*.nix` only — never bulk-reformat
- Shell: `shfmt -i 2 -s` on touched scripts; use Bash features only with a Bash shebang
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

## PARALLEL WORK AND HANDOFF
- Give each independently edited task its own branch, worktree, and Herdr Space. Resume the existing task Space rather than switching branches underneath a running agent. Keep one writer per checkout and one owner for shared-file changes.
- Keep a current task handoff at `git rev-parse --git-path HANDOFF.md`; use `~/.config/herdr/worktree-handoff.md` as the template. Record owner, exact path/branch/HEAD, scope, acceptance commands/results, running services/ports, next action, and integration status. Update the snapshot in place; do not store credentials or a chronological log.
- Validate the actual task checkout: from its root, run `bash home-manager/cli/dotfiles/update -n --system-flake "$PWD/nixos" --home-flake "$PWD/home-manager"`. Use an explicit hostname for the other laptop. A dry build plans dependencies; package changes also need relevant real build checks.
- Start with two concurrent editing agents when parallel work is requested; increase only with responsive interaction, acceptable build latency, and low memory/IO pressure. The 8 GiB laptop should run fewer heavy builds. Assign distinct mutable output directories and development ports.
- Integrate reviewed commits serially in a designated integration checkout and rerun affected checks. Confirm both a clean tree and saved/integrated commits before deleting a worktree. If ARC's Jira step fails after local cleanup, use `herdr-arc finish REPO KEY_OR_BRANCH` without recreating the checkout.
