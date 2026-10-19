{ pkgs, openrig, ... }:
let
  openrigPackage = pkgs.callPackage ./openrig/package.nix { inherit openrig; };
in
{
  home.file.".local/bin/rig".source = "${openrigPackage}/bin/rig";
  home.file.".local/bin/openrig-tui".source = "${openrigPackage}/bin/openrig-tui";
}
