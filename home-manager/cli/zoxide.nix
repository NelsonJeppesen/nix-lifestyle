# Rank visited directories for fast interactive navigation with zoxide.
{ pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.zoxide;
  };
}
