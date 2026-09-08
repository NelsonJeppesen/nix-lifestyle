# zoxide.nix - frecency-based directory navigation
{ pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.zoxide;
  };
}
