# Share the enabled MCP server catalogue across Home Manager-managed agent clients.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  memoryFile = "${config.home.homeDirectory}/.local/share/mcp-memory/memory.json";

  # Map GITHUB_TOKEN to GITHUB_PERSONAL_ACCESS_TOKEN.
  githubMcpServer = pkgs.writeShellApplication {
    name = "github-mcp-server-hm";
    runtimeInputs = [ pkgs.github-mcp-server ];
    text = ''
      export GITHUB_PERSONAL_ACCESS_TOKEN="''${GITHUB_PERSONAL_ACCESS_TOKEN:-''${GITHUB_TOKEN:-}}"
      exec github-mcp-server "$@"
    '';
  };

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
  ];
}
