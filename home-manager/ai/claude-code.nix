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
