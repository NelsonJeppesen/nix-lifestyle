{ ... }: {
  imports = [
    ./agent-deck.nix
    ./claude-code.nix
    ./codex.nix
    ./herdr.nix
    ./herdr-plus.nix
    # ./herdr-projects.nix
    ./herdr-remote.nix
    ./mcp.nix
    ./microsoft-365.nix
    ./opencode.nix
    ./openrig.nix
    ./paperclip.nix
    ./pi.nix
    # ./ralph.nix
    ./slack-mcp.nix
    ./packages.nix
    ./secrets.nix
    ./files.nix
  ];
}
