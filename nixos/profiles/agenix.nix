# agenix.nix - age-encrypted secrets management
#
# Pins agenix via builtins.fetchGit (per AGENTS.md "Dependency fetches") instead
# of relying on the legacy <agenix> NIX_PATH lookup, which required a manual
# `nix-channel --add` and was fragile across machines.
{ pkgs, ... }:
let
  agenix = builtins.fetchGit {
    url = "https://github.com/ryantm/agenix.git";
    ref = "main";
    # Pin a known revision; bump intentionally.
    rev = "b027ee29d959fda4b60b57566d64c98a202e0feb";
  };
in
{
  imports = [ "${agenix}/modules/age.nix" ];
  environment.systemPackages = [ (pkgs.callPackage "${agenix}/pkgs/agenix.nix" { }) ];
}
