{ pkgs, ... }: {
  imports = [
    ./nvf.nix
  ];

  home.packages = [
    pkgs.sqlite # Neovim plugin database
  ];
}
