{ ... }: {
  imports = [
    ./claude-code.nix
    ./codex.nix
    ./herdr.nix
    ./mcp.nix
    ./microsoft-365.nix
    ./opencode.nix
    ./pi.nix
    # ./ralph.nix
    ./serena.nix
    ./slack-mcp.nix
    ./packages.nix
    ./secrets.nix
    ./files.nix
  ];
}
