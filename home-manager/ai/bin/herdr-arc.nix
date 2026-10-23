# Shared by herdr.nix (keybinding) and herdr-plus.nix (quick actions).
# hmConfig is the Home Manager config: the Claude Code and mise packages and
# the Atlassian MCP URL come from the modules that own them.
{
  hmConfig,
  writeShellApplication,
  git,
  herdr,
  jq,
}:
writeShellApplication {
  name = "herdr-arc";
  runtimeInputs = [
    hmConfig.programs.claude-code.finalPackage
    hmConfig.programs.mise.package
    git
    herdr
    jq
  ];
  text = ''
    ATLASSIAN_MCP_URL=${hmConfig.programs.mcp.servers.atlassian.url}
  ''
  + builtins.readFile ./herdr-arc;
}
