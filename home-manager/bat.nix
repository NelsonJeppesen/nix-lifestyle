# bat.nix - syntax-aware file viewer
{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    package = pkgs.bat;
  };
}
