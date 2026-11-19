# Provide syntax-highlighted file previews through bat.
{ pkgs, ... }:
{
  programs.bat = {
    enable = true;
    package = pkgs.bat;
  };
}
