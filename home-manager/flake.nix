{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gitalias = {
      url = "github:GitAlias/gitalias";
      flake = false;
    };

    open-ralph-wiggum = {
      url = "github:Th0rgal/open-ralph-wiggum";
      flake = false;
    };

    pi-mcp-adapter = {
      url = "github:nicobailon/pi-mcp-adapter/v2.11.0";
      flake = false;
    };

    openrig = {
      url = "https://registry.npmjs.org/@openrig/cli/-/cli-0.6.4.tgz";
      flake = false;
    };

    paperclip = {
      url = "https://registry.npmjs.org/paperclipai/-/paperclipai-2026.1001.0.tgz";
      flake = false;
    };

    workiq = {
      url = "https://registry.npmjs.org/@microsoft/workiq/-/workiq-1.0.0.tgz";
      flake = false;
    };

    slack-mcp-server = {
      url = "github:korotovsky/slack-mcp-server/v1.3.0";
      flake = false;
    };

    agent-deck = {
      url = "github:asheshgoplani/agent-deck/v1.16.18";
      flake = false;
    };

    herdr-remote = {
      url = "github:dcolinmorgan/herdr-remote/v0.8.0";
      flake = false;
    };

    herdr-projects = {
      url = "github:eliasstravik/herdr-projects/v0.2.33";
      flake = false;
    };

    herdr-plus = {
      url = "github:cloudmanic/herdr-plus/v0.1.24";
      flake = false;
    };

    gnome-github-notifications-redux = {
      url = "github:NelsonJeppesen/gnome-github-notifications-redux/review-01";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flameshot = {
      url = "github:flameshot-org/flameshot/410cfae9e2ab32c376e3844c0fc41470362c3174";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nvf,
      agenix,
      gitalias,
      nix-index-database,
      gnome-github-notifications-redux,
      flameshot,
      open-ralph-wiggum,
      pi-mcp-adapter,
      openrig,
      paperclip,
      workiq,
      slack-mcp-server,
      agent-deck,
      herdr-remote,
      herdr-projects,
      herdr-plus,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          # binutils 2.46's ld.bfd rejects libghostty-vt's Zig-emitted
          # .eh_frame ("overlapping FDEs"); link with lld instead.
          (final: prev: {
            herdr = prev.herdr.overrideAttrs (o: {
              nativeBuildInputs = o.nativeBuildInputs ++ [ final.lld ];
              env = (o.env or { }) // {
                RUSTFLAGS = "-C link-arg=-fuse-ld=lld";
              };
            });
            # diff-cover 10.5.1's HTML integration tests fail against the
            # current nixpkgs toolchain; it's only a sqlfluff build dep.
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
              (pyFinal: pyPrev: {
                diff-cover = pyPrev.diff-cover.overridePythonAttrs { doCheck = false; };
              })
            ];
          })
        ];
      };
    in
    {
      # Single user configuration for "nelson"
      homeConfigurations."nelson" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix # User modules
          nvf.homeManagerModules.default # Neovim
          agenix.homeManagerModules.default # Secrets
          nix-index-database.homeModules.nix-index # Package index
        ];

        # Module inputs.
        extraSpecialArgs = {
          inherit
            nvf
            agenix
            gitalias
            nix-index-database
            gnome-github-notifications-redux
            flameshot
            open-ralph-wiggum
            pi-mcp-adapter
            openrig
            paperclip
            workiq
            slack-mcp-server
            agent-deck
            herdr-remote
            herdr-projects
            herdr-plus
            ;
        };
      };
    };
}
