# agenix.nix - age-encrypted secrets management
#
# `agenix` is provided as a flake input via specialArgs (see ../flake.nix).
{ pkgs, agenix, ... }:
{
  imports = [ agenix.nixosModules.default ];
  environment.systemPackages = [ agenix.packages.${pkgs.system}.default ];
}
