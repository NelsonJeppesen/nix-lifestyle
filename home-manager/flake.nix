{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      agenix,
      gitalias,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            flameshot = prev.flameshot.overrideAttrs (old: {
              version = "13.3.0-unstable-2026-01-25";
              src = prev.fetchFromGitHub {
                owner = "flameshot-org";
                repo = "flameshot";
                rev = "739a809557d8be3ee8f3f7d16dffd0cfd391de09";
                hash = "sha256-YCYwpVR7vTTKBmBwGt+C8nsuE0UfvJuo4plAeIbwIJU=";
              };
              patches = [
                ./patches/flameshot-load-missing-deps.patch
              ];
            });
          })
        ];
      };
    in
    {
      homeConfigurations."nelson" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
          agenix.homeManagerModules.default
        ];

        extraSpecialArgs = {
          inherit agenix gitalias;
        };
      };
    };
}
