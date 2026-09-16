{
  config,
  lib,
  pkgs,
  slack-mcp-server,
  ...
}:
let
  memoryFile = "${config.home.homeDirectory}/.local/share/mcp-memory/memory.json";

  slackMcpServer = pkgs.buildGoModule {
    pname = "slack-mcp-server";
    version = "1.3.0";
    src = slack-mcp-server;
    vendorHash = "sha256-+uQRODO9oL8mGKBmdghTxE6R9Fz+3GJFVTi17306gT8=";
    subPackages = [ "cmd/slack-mcp-server" ];
    ldflags = [
      "-s"
      "-w"
      "-X=github.com/korotovsky/slack-mcp-server/pkg/version.Version=v1.3.0"
      "-X=github.com/korotovsky/slack-mcp-server/pkg/version.BinaryName=slack-mcp-server"
    ];
    meta.mainProgram = "slack-mcp-server";
  };

  # Map GITHUB_TOKEN to GITHUB_PERSONAL_ACCESS_TOKEN.
  githubMcpServer = pkgs.writeShellApplication {
    name = "github-mcp-server-hm";
    runtimeInputs = [ pkgs.github-mcp-server ];
    text = ''
      export GITHUB_PERSONAL_ACCESS_TOKEN="''${GITHUB_PERSONAL_ACCESS_TOKEN:-''${GITHUB_TOKEN:-}}"
      exec github-mcp-server "$@"
    '';
  };

  # Read-only Slack tools.
  slackReadTools = [
    "conversations_history"
    "conversations_replies"
    "conversations_search_messages"
    "conversations_unreads"
    "channels_list"
    "channels_me"
    "usergroups_list"
    "users_search"
  ];

  # Listed write tools have no channel restrictions.
  slackWriteTools = slackReadTools ++ [
    "conversations_add_message"
    "reactions_add"
    "reactions_remove"
    "conversations_mark"
  ];
in
{
  programs.mcp = {
    enable = true;

    servers = {
      # Atlassian remote MCP (Jira / Confluence Cloud).
      atlassian = {
        url = "https://mcp.atlassian.com/v1/mcp";
        enabled = true;
      };

      # GitHub repos, PRs, issues, and actions. Token via the wrapper above.
      github = {
        command = lib.getExe githubMcpServer;
        args = [ "stdio" ];
        enabled = true;
      };

      # Terraform registry: modules, providers, and docs search.
      terraform = {
        command = lib.getExe pkgs.terraform-mcp-server;
        args = [ "stdio" ];
        enabled = true;
      };

      # Persistent knowledge-graph memory across sessions.
      memory = {
        command = lib.getExe pkgs.mcp-server-memory;
        env.MEMORY_FILE_PATH = memoryFile;
        enabled = true;
      };

      # Slack reads and writes.
      slack = {
        command = lib.getExe slackMcpServer;
        env.SLACK_MCP_ENABLED_TOOLS = lib.concatStringsSep "," slackWriteTools;
        enabled = true;
      };

      # Leave disabled servers commented to keep Claude settings writable.
      # k8s.command = lib.getExe pkgs.mcp-k8s-go;
    };
  };

  # Ensure the memory file's parent directory exists before the memory MCP
  # server is invoked; mcp-server-memory creates the JSON file itself.
  home.activation.mcpMemoryDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${builtins.dirOf memoryFile}"
  '';

  # Install the MCP server binaries so they can also be invoked from a shell,
  # and so a server toggled `enabled = true` resolves without a rebuild race.
  home.packages = [
    githubMcpServer
    pkgs.github-mcp-server
    pkgs.mcp-k8s-go
    pkgs.mcp-server-memory
    pkgs.terraform-mcp-server
    slackMcpServer
  ];
}
