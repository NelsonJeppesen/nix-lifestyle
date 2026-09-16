{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    package = pkgs.bat;
  };
}
