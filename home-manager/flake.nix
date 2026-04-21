# flake.nix - Home Manager flake entrypoint
#
# Defines all inputs (nixpkgs, home-manager, agenix, gitalias) and a single
# homeConfiguration output for user "nelson" on x86_64-linux.
#
{
  description = "Home Manager configuration";

  inputs = {
    # Track nixos-unstable for latest packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager for declarative user environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agenix: age-encrypted secrets management for NixOS and home-manager
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # GitAlias: community-curated collection of useful git aliases
    # Imported as a non-flake input so we can reference gitalias.txt directly
    gitalias = {
      url = "github:GitAlias/gitalias";
      flake = false;
    };

    # GitHub Notifications Redux: GNOME Shell extension for GitHub notifications
    gnome-github-notifications-redux = {
      url = "github:NelsonJeppesen/gnome-github-notifications-redux/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      agenix,
      gitalias,
      gnome-github-notifications-redux,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # Single user configuration for "nelson"
      homeConfigurations."nelson" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix # Main home-manager module (imports all others)
          agenix.homeManagerModules.default # Enable age-encrypted secrets
        ];

        # Pass extra arguments to all modules so they can access agenix and gitalias
        extraSpecialArgs = {
          inherit agenix gitalias gnome-github-notifications-redux;
        };
      };
    };
}
