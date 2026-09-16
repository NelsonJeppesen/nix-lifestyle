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

    serena = {
      url = "github:oraios/serena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pi-mcp-adapter = {
      url = "github:nicobailon/pi-mcp-adapter/v2.11.0";
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
      serena,
      pi-mcp-adapter,
      workiq,
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
          ./home.nix # User modules
          nvf.homeManagerModules.default # Neovim
          agenix.homeManagerModules.default # Secrets
          nix-index-database.homeModules.nix-index # Package index
        ];

        # Module inputs.
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
            workiq
            slack-mcp-server
            ;
        };
      };
    };
}
