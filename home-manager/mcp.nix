# mcp.nix - Model Context Protocol (MCP) server configuration
#
# MCP is a protocol for connecting AI coding assistants (like OpenCode) to
# external tool servers. This module configures the following MCP servers:
#
# - GitHub MCP: enables AI tools to interact with GitHub (PRs, issues, etc.)
# - Terraform MCP: provides Terraform registry documentation and module search
# - Kubernetes MCP: allows AI tools to query and manage Kubernetes resources
# - Memory MCP: persistent knowledge graph that survives across sessions
#
# The servers are registered with home-manager's MCP module so OpenCode
# and other MCP-compatible tools can discover and connect to them.
{ config, lib, pkgs, ... }:
let
  memoryFile = "${config.home.homeDirectory}/.local/share/mcp-memory/memory.json";
in
{
  programs.mcp = {
    enable = true;
    servers = {
      # GitHub MCP server: interact with GitHub repos, PRs, issues, and actions
      # Requires `stdio` subcommand to act as an MCP server over stdin/stdout,
      # and a personal access token via GITHUB_PERSONAL_ACCESS_TOKEN.
      # The token is sourced from $GITHUB_TOKEN already exported by `gh auth`.
      github = {
        command = lib.getExe pkgs.github-mcp-server;
        args = [ "stdio" ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_TOKEN}";
        };
      };
      # Terraform MCP server: search modules, providers, and registry docs
      terraform = {
        command = lib.getExe pkgs.terraform-mcp-server;
        args = [ "stdio" ];
      };
      # Kubernetes MCP server: query cluster resources, pods, logs, etc.
      k8s = {
        command = lib.getExe pkgs.mcp-k8s-go;
      };
      # Memory MCP server: persistent knowledge graph memory across sessions.
      # MEMORY_FILE_PATH pins storage to a stable XDG-style location so the
      # graph survives package updates and is easy to back up.
      memory = {
        command = lib.getExe pkgs.mcp-server-memory;
        env = {
          MEMORY_FILE_PATH = memoryFile;
        };
      };
    };
  };

  # Ensure the memory file's parent directory exists before the server
  # is invoked; mcp-server-memory will create the JSON file itself.
  home.activation.mcpMemoryDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${builtins.dirOf memoryFile}"
  '';

  # Also install MCP server binaries into the environment
  # so they can be invoked directly from the shell if needed
  home.packages = [
    pkgs.github-mcp-server
    pkgs.mcp-grafana # Grafana MCP server (for dashboard/alert queries)
    pkgs.mcp-k8s-go
    pkgs.mcp-server-memory
    pkgs.terraform-mcp-server
  ];
}
