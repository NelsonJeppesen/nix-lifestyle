{ pkgs, ... }:
{
  programs.mcp = {
    enable = true;
    servers = {
      github = {
        command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      };
      terraform = {
        command = "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server";
      };
      k8s = {
        command = "${pkgs.mcp-k8s-go}/bin/mcp-k8s-go";
      };
    };
  };

  # Make MCP servers available in environment
  home.packages = [
    pkgs.github-mcp-server
    pkgs.terraform-mcp-server
    pkgs.mcp-k8s-go
  ];
}
