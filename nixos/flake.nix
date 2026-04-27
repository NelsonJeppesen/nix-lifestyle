# flake.nix - NixOS system layer flake entrypoint
#
# Defines inputs (nixpkgs, agenix, disko) and one nixosConfigurations
# output per machine in ./machines/. Hostname dispatch is now flake-native:
# `nixos-rebuild switch --flake /etc/nixos#<hostname>` (inferred from
# $HOSTNAME if omitted, since output names match real hostnames).
#
{
  description = "NixOS system configuration";

  inputs = {
    # Track nixos-unstable for latest packages (matches home-manager flake)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # agenix: age-encrypted secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disko: declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      disko,
      ...
    }:
    let
      system = "x86_64-linux";

      # Helper: build a nixosSystem for a given hostname.
      # The hostname must match a file under ./machines/<hostname>.nix.
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit agenix disko; };
          modules = [
            ./configuration.nix
            ./machines/${hostname}.nix
            {
              networking.hostName = hostname;
              nixpkgs.hostPlatform = system;
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        lg-gram-14-2022 = mkSystem "lg-gram-14-2022";
        lg-gram-17-2022 = mkSystem "lg-gram-17-2022";
        lg-gram-pro-17-2025 = mkSystem "lg-gram-pro-17-2025";
        macbook12-0 = mkSystem "macbook12-0";
        macbook12-1 = mkSystem "macbook12-1";
        macbook12-2 = mkSystem "macbook12-2";
        openclaw = mkSystem "openclaw";
      };
    };
}
