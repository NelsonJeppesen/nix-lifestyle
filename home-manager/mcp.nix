# mcp.nix - Model Context Protocol (MCP) server configuration
#
# MCP is a protocol for connecting AI coding assistants (like OpenCode) to
# external tool servers. This module configures three MCP servers:
#
# - GitHub MCP: enables AI tools to interact with GitHub (PRs, issues, etc.)
# - Terraform MCP: provides Terraform registry documentation and module search
# - Kubernetes MCP: allows AI tools to query and manage Kubernetes resources
#
# The servers are registered with home-manager's MCP module so OpenCode
# and other MCP-compatible tools can discover and connect to them.
{ pkgs, ... }:
{
  programs.mcp = {
    enable = true;
    servers = {
      # GitHub MCP server: interact with GitHub repos, PRs, issues, and actions
      github = {
        command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      };
      # Terraform MCP server: search modules, providers, and registry docs
      terraform = {
        command = "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server";
      };
      # Kubernetes MCP server: query cluster resources, pods, logs, etc.
      k8s = {
        command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
      };
    };
  };

  # Also install MCP server binaries into the environment
  # so they can be invoked directly from the shell if needed
  home.packages = [
    pkgs.github-mcp-server
    pkgs.mcp-grafana # Grafana MCP server (for dashboard/alert queries)
    pkgs.mcp-k8s-go
    pkgs.terraform-mcp-server
  ];
}
