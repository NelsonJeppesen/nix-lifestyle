# Wrap Slack with Wayland and a private cache using default background scheduling.
{ pkgs, lib, ... }:
let
  # Mirrors the Wayland/GPU tuning in chrome.nix.
  slackFlags = lib.concatStringsSep " " [
    "--ozone-platform-hint=auto" # pick Wayland when available, X11 otherwise
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
    "--ignore-gpu-blocklist" # allow HW accel on the iGPU (matches chrome.nix)
    "--enable-wayland-ime=false" # Disable Wayland input-method composition

    # Push rasterization onto the iGPU instead of the CPU, and skip the
    # CPU->GPU texture copy (matches chrome.nix). Costs VRAM, buys smoother
    # scrolling in long channels.
    "--enable-gpu-rasterization"
    "--enable-zero-copy"

    # Electron controls background timers and V8 heap limits. Normal throttling
    # lets hidden windows yield CPU and memory to active applications.

    # Request a volatile cache in the session runtime directory. These are
    # cache budgets, not reservations or measured usage; leave room for other
    # desktop services sharing the same tmpfs.
    "--disk-cache-dir=$SLACK_CACHE_DIR"
    "--disk-cache-size=805306368" # 768 MiB
    "--media-cache-size=201326592" # 192 MiB
  ];

  slackWrapped = pkgs.symlinkJoin {
    name = "slack-wayland";
    paths = [ pkgs.slack ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    # Wrap Slack with launch flags.
    postBuild = ''
      wrapProgram $out/bin/slack \
        --run 'SLACK_CACHE_DIR="''${XDG_RUNTIME_DIR:-''${XDG_CACHE_HOME:-$HOME/.cache}}/slack-cache"; mkdir -p -m 700 "$SLACK_CACHE_DIR"' \
        --add-flags ${lib.escapeShellArg slackFlags}

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
