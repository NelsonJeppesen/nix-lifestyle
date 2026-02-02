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
      pkgs = nixpkgs.legacyPackages.${system};
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
