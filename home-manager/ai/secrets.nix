{ config, ... }: {
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
}
