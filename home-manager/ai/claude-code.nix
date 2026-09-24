{ ... }:
{
  programs.zsh.shellAliases = {
    c = "claude";
    cc = "claude --continue";
  };

  # Suppress the "How is Claude doing this session?" feedback prompt.
  # Env var rather than programs.claude-code.settings so ~/.claude/settings.json
  # stays a mutable file Claude Code can write to.
  home.sessionVariables.CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };
}
