{ lib, pkgs, ... }:
let
  hostname = lib.removeSuffix "\n" (builtins.readFile "/etc/nixos/.hostname");
in
{
  networking.hostName = hostname;
  networking.domain = "home.arpa";

  imports = [
    # map host name to nix import
    ./machines/${hostname}.nix

    # default profiles
    ./profiles/agenix.nix
    ./profiles/shared.nix
  ];
}
