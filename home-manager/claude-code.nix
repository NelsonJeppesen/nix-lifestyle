# claude-code.nix - Claude Code AI coding assistant configuration
{ ... }:
{
  programs.zsh.shellAliases = {
    c = "claude";
    cc = "claude --continue";
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };
}
