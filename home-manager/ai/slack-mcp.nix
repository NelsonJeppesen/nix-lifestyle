{ pkgs, ... }:
let
  # Python with the AES primitive needed to decrypt the Chromium cookie.
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.cryptography ]);

  slack-stealth-tokens = pkgs.stdenvNoCC.mkDerivation {
    name = "slack-stealth-tokens";
    src = ./bin/slack-stealth-tokens;
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    # secret-tool (libsecret) reads the Slack Safe Storage keyring entry;
    # falls back to the Chromium "peanuts" default when absent.
    buildInputs = [
      pythonEnv
      pkgs.libsecret
    ];
    installPhase = ''
      install -Dm755 "$src" "$out/bin/slack-stealth-tokens"
      substituteInPlace "$out/bin/slack-stealth-tokens" \
        --replace-fail "/usr/bin/env python3" "${pythonEnv}/bin/python3"
      wrapProgram "$out/bin/slack-stealth-tokens" \
        --prefix PATH : "${pkgs.libsecret}/bin"
    '';
  };
in
{
  home.packages = [ slack-stealth-tokens ];

  programs.zsh.initContent = ''
    if [[ -z ''${SLACK_MCP_XOXC_TOKEN:-} || -z ''${SLACK_MCP_XOXD_TOKEN:-} ]]; then
      eval "$(slack-stealth-tokens 2>/dev/null)" || true
    fi
  '';
}
