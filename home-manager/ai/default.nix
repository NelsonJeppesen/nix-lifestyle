{ config, pkgs, ... }: {
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
  ];

  home.packages = [
    # pkgs.ralphex
    # pkgs.codex
    #pkgs.codex
  ];

  age.secrets = {
    # Private OpenCode command.
    # "opencode.secret1" = {
    #   file = "/etc/secrets/encrypted/opencode.secret1.age";
    #   path = "${config.home.homeDirectory}/.config/opencode/commands/secret1.md";
    # };
    # Per-host tunnel tokens.
    "opencode-web.tunnel-token.lg-gram-14" = {
      file = "/etc/secrets/encrypted/opencode-web.tunnel-token.lg-gram-14.age";
      path = "${config.home.homeDirectory}/.config/opencode-web/cloudflared/token.lg-gram-14";
    };
    "opencode-web.tunnel-token.lg-gram-17" = {
      file = "/etc/secrets/encrypted/opencode-web.tunnel-token.lg-gram-17.age";
      path = "${config.home.homeDirectory}/.config/opencode-web/cloudflared/token.lg-gram-17";
    };
  };
  home.file.".config/opencode/open-plan-annotator.json".source = ./dotfiles/open-plan-annotator.json; # open-plan-annotator: hand off approved plan to `sisyphus`
}
