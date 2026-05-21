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

    # comin: GitOps for NixOS — pulls this flake from a Git remote and
    # switches the system on every push. Currently only enabled on
    # `openclaw` (see profiles/comin.nix).
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager: NixOS module form is used on the `opencode` host so
    # nelson's home-manager opencode config (../home-manager/opencode.nix)
    # configures the headless `opencode serve` instance running as nelson.
    # The user-layer flake at home-manager/flake.nix pins its own copy for
    # interactive laptops; this input is independent and only consumed by
    # nixos/profiles/opencode.nix.
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      disko,
      comin,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      # Helper: build a nixosSystem for a given hostname.
      # The hostname must match a file under ./machines/<hostname>.nix.
      mkSystem =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              agenix
              disko
              comin
              home-manager
              ;
          };
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
        opencode = mkSystem "opencode";
        macbook12-1 = mkSystem "macbook12-1";
        macbook12-2 = mkSystem "macbook12-2";
        openclaw = mkSystem "openclaw";
      };
    };
}
