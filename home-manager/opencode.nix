{ ... }:
{
  programs.zsh.shellAliases = {
    oc = "opencode";
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    commands = {
      # Inline content
      changelog = ''
        # Update Changelog Command
        Update CHANGELOG.md with new entries.
      '';
    };

    agents = {
      # Inline content
      code-reviewer = ''
        # Code Reviewer Agent
        Specialized code review assistant.
      '';
    };
  };
}
