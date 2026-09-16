{ pkgs, ... }: {
  home.packages = [
    pkgs.sqlite # Neovim plugin database
  ];
}
