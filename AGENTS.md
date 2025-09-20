# AGENTS.md – Nix Lifestyle Repo Guidance
Build (system): `sudo nixos-rebuild switch` (repo linked at /etc/nixos); dry: `sudo nixos-rebuild build`
Build (home): `home-manager switch`; dry: `home-manager build`
"Single test": treat a successful dry build (no activation) as test; no other tests exist
Format Nix: run `nixfmt` (RFC style) only on touched *.nix before commit
Shell snippets: if editing, run `shfmt -i 2 -s` (keep POSIX-safe / quote vars)
EditorConfig: 2-space indent, UTF-8, LF, trim trailing whitespace, final newline
Naming: hyphen-case files (`macbook12-0.nix`), snake_case attrs, short logical profile names
Module structure: enable flags + package lists first; large blobs (Lua, extraConfig) last
Imports: group std (builtins/pkgs), then local `profiles/`, `machines/`, then overlays
Avoid flakes (legacy channels in use); do not introduce `flake.nix` unless requested
Secrets: never commit decrypted secrets; use `age.secrets` references only
Git: signed commits required (SSH); messages: imperative, why > what, <=72 chars
LSP/formatters: rely on existing Neovim config; do not add redundant format tools
Error handling: avoid `throw`; prefer conditional attrs / option flags; shell funcs validate args
Dependency fetches: use `builtins.fetchGit` in a `let` binding at top (e.g., gitalias)
Keep diffs minimal; prefer new module over inflating existing unrelated one
Do not auto-upgrade style across repo without functional change approval
Large refactors: propose plan first; keep functional + formatting in single commit
No Cursor/Copilot rule files present; follow this document for agent behavior
