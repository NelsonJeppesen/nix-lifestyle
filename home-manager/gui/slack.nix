{ pkgs, lib, ... }:
let
  # Mirrors the Wayland/GPU tuning in chrome.nix.
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
    # Wrap Slack with launch flags.
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
