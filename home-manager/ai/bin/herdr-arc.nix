# Shared by herdr.nix (keybinding) and herdr-plus.nix (quick actions).
# hmConfig is the Home Manager config: the Claude Code and mise packages and
# the Atlassian MCP URL come from the modules that own them. systemd and
# util-linux carry systemd-cat and setsid for the detached `new` and logging.
{
  hmConfig,
  writeShellApplication,
  git,
  coreutils,
  findutils,
  gawk,
  gnugrep,
  gnused,
  herdr,
  jq,
  systemd,
  util-linux,
}:
writeShellApplication {
  name = "herdr-arc";
  runtimeInputs = [
    hmConfig.programs.claude-code.finalPackage
    hmConfig.programs.mise.package
    git
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    herdr
    jq
    systemd
    util-linux
  ];
  text = ''
    ATLASSIAN_MCP_URL=${hmConfig.programs.mcp.servers.atlassian.url}
  ''
  + builtins.readFile ./herdr-arc;
}
