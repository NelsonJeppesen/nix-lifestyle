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

  #networking.extraHosts = ''
  #  52.4.157.168 thrall-app.alchemer.com
  #'';
}
