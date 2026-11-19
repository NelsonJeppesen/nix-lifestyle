# Compose AI tools; commented imports are optional features, not installed services.
{ ... }: {
  imports = [
    ./agent-deck.nix
    ./claude-code.nix
    ./codex.nix
    ./herdr.nix
    ./herdr-plus.nix
    # ./herdr-projects.nix
    ./mcp.nix
    ./microsoft-365.nix
    ./opencode.nix
    ./openrig.nix
    ./paperclip.nix
    ./pi.nix
    # ./ralph.nix
    ./packages.nix
    ./secrets.nix
    ./files.nix
  ];
}
