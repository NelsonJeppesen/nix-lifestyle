{ pkgs, ... }:
{
  programs.zsh.shellAliases = {
    # Connect to the daemon server running on port 4096
    o = "opencode";
    ods = "opencode run '/summary daily'  -m 'github-copilot/claude-sonnet-4.5'";
    ows = "opencode run '/summary weekly' -m 'github-copilot/claude-sonnet-4.5'";
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

      summary = ''
        # Shell History Summary Command
        Analyze the user's Atuin shell history and generate a summary of activities.

        ## Usage:
        - `/summary` or `/summary day` - Last 24 hours (daily summary)
        - `/summary week` - Last 7 days (weekly summary)
        - `/summary month` - Last 30 days (monthly summary)
        - `/summary <N>d` - Last N days (e.g., `/summary 3d` for last 3 days)

        ## Instructions:
        1. Parse the argument to determine the time period:
           - No argument or "day" → 24 hours (limit 2000)
           - "week" → 7 days (limit 5000)
           - "month" → 30 days (limit 10000)
           - "<N>d" → N days (adjust limit appropriately: ~300*N commands)

        2. Query Atuin history using: `atuin search --limit <LIMIT> --format "{time}\t{command}" --filter-mode global --after "<PERIOD>"`

        3. Parse and analyze the command history to identify meaningful work (filter out noise like cd, ls, clear, history)

        4. Generate a **concise summary limited to 30 lines maximum** organized by:
           - Projects/repositories worked on
           - Infrastructure/DevOps activities (Terraform, AWS, K8s, etc.)
           - Development tasks
           - System administration tasks

        ## Output Format:
        Provide a markdown summary with:
        - Date range covered
        - Main projects/activities (bullet points)
        - Key accomplishments or infrastructure changes
        - **Maximum 30 lines total**

        Adjust detail level based on time period:
        - Daily: Very concise, focused on today's work
        - Weekly: Summarized patterns and major accomplishments
        - Monthly: High-level overview with key themes
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
