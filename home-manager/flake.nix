# flake.nix - Home Manager flake entrypoint
#
# Defines the pinned package/tool inputs and a single
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

    # Weekly prebuilt nix-index database. This avoids generating an index
    # locally; comma uses the smaller binaries-only database.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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

    # Open Ralph Wiggum: CLI that wraps an AI coding agent in an iterative
    # "ralph loop". Non-flake input: it's a Bun/TypeScript project with zero
    # runtime deps, so ralph.nix wraps its ralph.ts source directly with bun.
    open-ralph-wiggum = {
      url = "github:Th0rgal/open-ralph-wiggum";
      flake = false;
    };

    # Serena: semantic retrieval and symbol-level editing tools for OpenCode.
    serena = {
      url = "github:oraios/serena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MCP adapter for Pi. Built declaratively in pi.nix; no `pi install` or
    # activation-time npm download is needed.
    pi-mcp-adapter = {
      url = "github:nicobailon/pi-mcp-adapter/v2.11.0";
      flake = false;
    };

    # Slack MCP server source. Built in opencode.nix so the MCP binary is
    # pinned and does not depend on an imperative npx download.
    slack-mcp-server = {
      url = "github:korotovsky/slack-mcp-server/v1.3.0";
      flake = false;
    };

    # GitHub Notifications Redux: GNOME Shell extension for GitHub notifications
    gnome-github-notifications-redux = {
      url = "github:NelsonJeppesen/gnome-github-notifications-redux/review-01";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flameshot built from upstream master (post-v14.0.rc1) which includes
    # PR #4664 — the fix for the empty parent_window xdg-desktop-portal bug
    # that breaks `flameshot gui` intermittently on GNOME Wayland.
    # nixpkgs still ships v13.3.0, which lacks the fix. Pinned to the merge
    # commit so updates are explicit. Drop once nixpkgs ships a release that
    # includes 410cfae.
    flameshot = {
      url = "github:flameshot-org/flameshot/410cfae9e2ab32c376e3844c0fc41470362c3174";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      agenix,
      gitalias,
      nix-index-database,
      gnome-github-notifications-redux,
      flameshot,
      open-ralph-wiggum,
      serena,
      pi-mcp-adapter,
      slack-mcp-server,
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
          nix-index-database.homeModules.nix-index # Prebuilt nix-index database + comma
        ];

        # Pass extra arguments to all modules so they can access agenix and gitalias
        extraSpecialArgs = {
          inherit
            agenix
            gitalias
            nix-index-database
            gnome-github-notifications-redux
            flameshot
            open-ralph-wiggum
            serena
            pi-mcp-adapter
            slack-mcp-server
            ;
        };
      };
    };
}
