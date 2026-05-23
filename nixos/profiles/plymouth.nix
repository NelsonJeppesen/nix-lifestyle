# plymouth.nix - Plymouth boot splash with rotating theme.
#
# A whitelist of themes from `adi1090x-plymouth-themes` is provided; the
# active theme is picked deterministically from a hash of
# `config.system.nixos.version` + `config.system.nixos.revision`, i.e.
# the pinned nixpkgs. Theme rotates every time `flake.lock` advances
# nixpkgs (e.g. `nh os switch -u`) and is stable across same-lock
# rebuilds, keeping the build reproducible.
#
# `system.nixos.label` is forced to embed the chosen theme so it shows
# up in the systemd-boot menu entry title — there is no per-generation
# title hook in NixOS; the label is the cleanest carrier.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  themes = [
    "black_hud"
    "circle_hud"
    "colorful_loop"
    "connect"
    "double"
    "hexagon_dots_alt"
    "hexagon_hud"
    "lone"
  ];

  # Seed: nixpkgs version + revision. Independent of system.nixos.label,
  # so we can safely override the label below without recursion.
  seed =
    (config.system.nixos.version or "unknown") + "/" + (config.system.nixos.revision or "unknown");
  digest = builtins.hashString "sha256" seed;

  # Hex char -> int via lookup; fold first 8 chars into an int.
  hexVal = {
    "0" = 0;
    "1" = 1;
    "2" = 2;
    "3" = 3;
    "4" = 4;
    "5" = 5;
    "6" = 6;
    "7" = 7;
    "8" = 8;
    "9" = 9;
    "a" = 10;
    "b" = 11;
    "c" = 12;
    "d" = 13;
    "e" = 14;
    "f" = 15;
  };
  hexToInt = s: lib.foldl' (acc: c: acc * 16 + hexVal.${c}) 0 (lib.stringToCharacters s);
  idx = lib.mod (hexToInt (builtins.substring 0 8 digest)) (builtins.length themes);
  selected = builtins.elemAt themes idx;
in
{
  # Surface the picked theme in the boot menu entry title by adding a
  # tag. NixOS builds the default label as
  # "<version>-<tag1>-<tag2>...-<codename>", so adding a tag here makes
  # the systemd-boot entry read e.g. "NixOS 26.05...-theme.hexagon_hud,
  # Linux 6.x" without us having to reconstruct the whole label.
  system.nixos.tags = [ "${selected}" ];

  boot.plymouth = {
    enable = true;
    theme = selected;
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = themes;
      })
    ];
  };
}
