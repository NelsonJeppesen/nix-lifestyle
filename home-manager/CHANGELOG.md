# Changelog

All notable changes to this project are documented here. This file was
reconstructed retroactively from existing commit history (no prior tags).
Commit hashes are included for traceability.

## [Unreleased]
- (No unreleased changes yet)

## [0.1.0] - 2025-09-21
### Added
- Neovim: precognition plugin to help motion training (b76dff5)
- Documentation: AGENTS guidance / contribution notes (b9fd341)
- UI: add icons (1d95943)
- Neovim: plugin aiding with color codes (417cd82)

### Changed
- Neovim: migrate portions of VimL config to Lua (80f4025, dabcae2)
- Keybindings: unblock Esc, experiment with blocking hjkl for training (1361a41) then later remove block (131208c)
- Terminal (kitty): adopt native dark/light color scheme (cb5e239); custom bright palette tweaks (a00b5e8)
- Terminal: introduce quake-style kitty kitten replacing prior tool (eb1099e)
- General: assorted tidy / misc / drift / tweak adjustments (multiple "misc", "tidy", "tweak" commits incl. 4a5ca4f, f3e3f86, b696725, 71cdde6, 13cdfeb, 1083bc7, a302b64, 8037c2c, bdced78, fb913e1, 9e4868f, d014b48, f47fbaf, e4670e9, ae59527, 5eff275)
- Git/Config: remove circular loop (cc84fd8)
- README updates (c5bc786)

### Removed
- Drop random theme shell helper (0e19c69)
- Drop ddterm terminal in favor of kitty quake kitten (eb1099e)

### Notes
- Many historical commits used terse messages (e.g. "misc"). Grouped under
  General where specific intent was not discernible from the message alone.
- Future: prefer descriptive commit messages to yield clearer changelog diffs.

[0.1.0]: https://github.com/NelsonJeppesen/nix-lifestyle/commit/8d7fcc0
