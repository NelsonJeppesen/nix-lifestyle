# Resolve project tool versions through mise when entering an interactive shell.
{ ... }:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
  };
}
