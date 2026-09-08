# slack-mcp.nix - helper for capturing Slack stealth-mode MCP credentials
#
# The Slack MCP server (configured in opencode.nix) runs in "stealth mode":
# instead of an OAuth app it reuses the logged-in Slack desktop app's own
# session via two secrets, read from the environment at launch:
#   SLACK_MCP_XOXC_TOKEN  workspace API token (Local Storage leveldb)
#   SLACK_MCP_XOXD_TOKEN  `d` session cookie (encrypted Cookies sqlite)
#
# `slack-stealth-tokens` extracts and decrypts both straight from
# ~/.config/Slack so they never have to be copied by hand out of DevTools.
# Interactive Zsh sessions load them automatically when Slack is signed in;
# extraction failures stay quiet so opening a shell never fails.
#
# Typical use:
#   eval "$(slack-stealth-tokens)"       # load into the current shell
#   slack-stealth-tokens --envrc >> secret.env
#
# Packaged via writeShellApplication-style wrapping (writeShellScriptBin +
# an explicit interpreter) so shellcheck isn't run on Python and the
# cryptography dependency is pinned onto PATH.
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
