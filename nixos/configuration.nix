# configuration.nix - Top-level NixOS entry point
#
# Resolves the host name from /etc/nixos/.hostname and dispatches to the
# matching per-machine module under ./machines/. Always pulls in the
# baseline `agenix` (secrets) and `shared` (cross-host common) profiles.
#
# Adding a new machine: drop a `<hostname>.nix` under ./machines/ and
# point /etc/nixos/.hostname at that name.
{ lib, pkgs, ... }:
let
  hostname = lib.removeSuffix "\n" (builtins.readFile "/etc/nixos/.hostname");
in
{
  networking.hostName = hostname;
  networking.domain = "home.arpa";

  imports = [
    # Map host name to its machine-specific module
    ./machines/${hostname}.nix

    # Default profiles applied on every host
    ./profiles/agenix.nix
    ./profiles/shared.nix
  ];
}
