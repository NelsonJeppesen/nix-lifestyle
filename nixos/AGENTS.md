# AGENTS.md – nixos/ (system layer)

Flake-based NixOS config. Entry: `flake.nix` exposes one `nixosConfigurations.<hostname>` per file in `machines/`. Each output is built from `configuration.nix` (cross-host baseline) + `machines/<host>.nix` + `{ networking.hostName = "<host>"; }`. `flake.nix`'s `mkSystem` helper wires this together and forwards `agenix` and `disko` via `specialArgs`.

## STRUCTURE
- `flake.nix` / `flake.lock` – inputs (`nixpkgs` unstable, `agenix`, `disko`) + outputs
- `configuration.nix` – cross-host baseline; imports `profiles/agenix.nix` + `profiles/shared.nix`. No machine-specific config; no hostname dispatch.
- `machines/<host>.nix` – per-host module; imports a curated set of profiles + hardware quirks
- `profiles/` – reusable bundles (one concern per file); imported by machine modules
- `nelson.{jpeg,png}` – user avatar referenced by GNOME profile

No `overlays/` directory exists. Inline overrides live in the profile that uses them.

## WHERE TO LOOK
| Task                           | Location                                           |
|--------------------------------|----------------------------------------------------|
| Add a new host                 | copy a `machines/*.nix` → add it to `nixosConfigurations` in `flake.nix` |
| Tweak GPU/power for laptops    | `profiles/intel.nix`, `profiles/laptop_power.nix`, `profiles/lg_gram_common.nix` |
| Disk layout / btrfs / LUKS     | `profiles/x86_64.nix` (disko)                      |
| K3s server (macbook cluster)   | `profiles/k3s.nix`, `profiles/macbook12-server.nix`|
| Boot/audio/bluetooth           | `profiles/desktop.nix`                             |
| GNOME strip + XKB              | `profiles/gnome.nix`                               |
| Firewall, VPN, networkd        | `profiles/networking.nix`, `profiles/wifi.nix`, `profiles/tailscale.nix` |
| Add an age-backed system secret| edit `age.secrets` in the relevant profile         |

## CONVENTIONS (layer-specific)
- Machine file = imports + hardware-only overrides; push reusable logic into a profile
- Profile naming: short logical name (`intel`, `desktop`, `k3s`); hyphenate hardware specifics (`lg_gram_common` is snake-case for legacy reasons — match neighbors when adding)
- External deps: add as a flake input in `flake.nix`, follow `nixpkgs`, plumb through `specialArgs` in `mkSystem`, accept as a function arg in the consuming profile (see `profiles/agenix.nix`, `profiles/x86_64.nix`)
- Authenticated package overlays: read decrypted secret via `builtins.readFile config.age.secrets.<name>.path`

## ANTI-PATTERNS
- Adding logic to `configuration.nix` beyond cross-host baseline imports
- Importing a profile from another profile — machines compose; profiles stay leaf
- Hardcoding a hostname inside a profile — use `config.networking.hostName` checks if conditional
- Reintroducing `builtins.fetchGit` / `fetchTarball` for inputs already available as flakes
- Forgetting to register a new machine file in `flake.nix` `nixosConfigurations`

## BUILD
```
sudo nixos-rebuild switch --flake /etc/nixos          # host inferred from $HOSTNAME
sudo nixos-rebuild switch --flake /etc/nixos#<host>   # explicit
sudo nixos-rebuild build  --flake /etc/nixos --dry-run
```
`--impure` may be required if a host's profile reads `age.secrets` paths during eval.
