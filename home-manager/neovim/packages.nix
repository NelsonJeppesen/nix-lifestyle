# Provide external runtime tools used by editor plugins.
{ pkgs, ... }: {
  home.packages = [
    pkgs.sqlite # Neovim plugin database
  ];
}
