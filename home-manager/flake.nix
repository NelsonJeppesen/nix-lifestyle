# flake.nix - Home Manager flake entrypoint
#
# Defines all inputs (nixpkgs, home-manager, agenix, gitalias) and a single
# homeConfiguration output for user "nelson" on x86_64-linux.
#
# Overlays are used to patch upstream packages that have bugs or need
# unreleased fixes (see the flameshot overlay below).
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
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # Flameshot overlay: pull the latest unreleased commit to fix a bug
          # where clipboard copy and the GNOME Wayland DBus integration are
          # broken in the current stable release.
          #
          # Upstream bug: https://github.com/flameshot-org/flameshot/issues/2848
          #
          # This pins flameshot to an unreleased commit (2026-01-25) from the
          # flameshot-org/flameshot repo that contains the fix. A custom CMake
          # patch is also applied so the build works in the Nix sandbox (replaces
          # FetchContent network calls with find_package for QtColorWidgets and
          # QHotKey dependencies).
          (final: prev: {
            flameshot = prev.flameshot.overrideAttrs (old: {
              version = "13.3.0-unstable-2026-01-25";
              src = prev.fetchFromGitHub {
                owner = "flameshot-org";
                repo = "flameshot";
                rev = "739a809557d8be3ee8f3f7d16dffd0cfd391de09";
                hash = "sha256-YCYwpVR7vTTKBmBwGt+C8nsuE0UfvJuo4plAeIbwIJU=";
              };
              # Patch CMakeLists.txt to use find_package instead of FetchContent
              # so dependencies resolve from Nix store instead of fetching from
              # the network during build (which is blocked in the Nix sandbox)
              patches = [
                ./patches/flameshot-load-missing-deps.patch
              ];
            });
          })
        ];
      };
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
