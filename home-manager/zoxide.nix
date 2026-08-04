# zoxide.nix - frecency-based directory navigation
{ pkgs, ... }:
{
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
    package = pkgs.zoxide;
  };
}
