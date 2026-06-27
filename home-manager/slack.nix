# slack.nix - Slack desktop client with native-Wayland + GPU flags
#
# Stock `pkgs.slack` is bare Electron: its .desktop launcher runs `slack -s %U`
# with no display flags, so on a Wayland session it falls back to XWayland with
# software compositing — sluggish and blurry on the LG Gram's 2880x1800 HiDPI
# panel. This module wraps Slack so the launcher carries the same Wayland/GPU/
# VAAPI switches used for Chrome (chrome.nix), making it render natively on
# Wayland with hardware video decode (huddles/screen-share).
#
# Slack's top-level `override` does NOT expose `commandLineArgs` (the upstream
# package bakes flags in via makeWrapper internally), so we wrap with
# symlinkJoin + makeWrapper instead of `.override`, and rewrite the .desktop
# Exec line to point at the wrapped binary.
{ pkgs, lib, ... }:
let
  # Mirrors the Wayland/GPU tuning in chrome.nix. Slack is Electron/Chromium,
  # so the same Ozone + ANGLE + VAAPI switches apply.
  slackFlags = lib.concatStringsSep " " [
    "--ozone-platform-hint=auto" # pick Wayland when available, X11 otherwise
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder,VaapiVideoEncoder"
    "--ignore-gpu-blocklist" # allow HW accel on the iGPU (matches chrome.nix)
    "--enable-wayland-ime=false" # IME off -> lower input latency (matches kitty)
  ];

  slackWrapped = pkgs.symlinkJoin {
    name = "slack-wayland";
    paths = [ pkgs.slack ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    # 1. Append the flags to the real binary via a wrapper.
    # 2. Rewrite the desktop entry's Exec line to launch the wrapper, so the
    #    GNOME app grid / <Super>s shortcut inherit the flags too. The stock
    #    entry is `Exec=<store>/bin/slack -s %U`; we replace the absolute
    #    binary path (and keep `-s %U`).
    postBuild = ''
      wrapProgram $out/bin/slack \
        --add-flags "${slackFlags}"

      if [ -f $out/share/applications/slack.desktop ]; then
        rm $out/share/applications/slack.desktop
        substitute ${pkgs.slack}/share/applications/slack.desktop \
          $out/share/applications/slack.desktop \
          --replace-fail "${pkgs.slack}/bin/slack" "$out/bin/slack"
      fi
    '';
  };
in
{
  home.packages = [ slackWrapped ];
}
