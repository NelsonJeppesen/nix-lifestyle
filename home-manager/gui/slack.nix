{ pkgs, lib, ... }:
let
  # Mirrors the Wayland/GPU tuning in chrome.nix.
  slackFlags = lib.concatStringsSep " " [
    "--ozone-platform-hint=auto" # pick Wayland when available, X11 otherwise
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder,VaapiVideoEncoder,CanvasOopRasterization"
    "--ignore-gpu-blocklist" # allow HW accel on the iGPU (matches chrome.nix)
    "--enable-wayland-ime=false" # IME off -> lower input latency (matches kitty)

    # Push rasterization onto the iGPU instead of the CPU, and skip the
    # CPU->GPU texture copy (matches chrome.nix). Costs VRAM, buys smoother
    # scrolling in long channels.
    "--enable-gpu-rasterization"
    "--enable-zero-copy"

    # Responsiveness: Slack is one window you Alt-Tab into constantly, so keep
    # its renderer at full priority rather than letting Chromium throttle and
    # deprioritize it while hidden. This is the "spend RAM/CPU instead of
    # conserving it" tradeoff -- costs some idle battery, removes the sluggish
    # first second after switching back.
    "--disable-renderer-backgrounding" # bg renderer keeps normal process priority
    "--disable-background-timer-throttling" # don't clamp timers to 1 Hz when hidden
    "--disable-backgrounding-occluded-windows" # covered != background (matches chrome.nix)
    "--disable-features=IntensiveWakeUpThrottling" # no 1/min wake budget after 5 min hidden

    # Give V8 an 8 GiB old-space instead of the ~2 GiB default, and a 64 MiB
    # young generation instead of ~16 MiB. Neither is preallocated -- they are
    # ceilings, and V8 scales its growth heuristics off them, so raising the
    # ceilings is what actually buys the headroom: the heap runs further before
    # each major GC, and short-lived objects (every rendered message, every
    # websocket frame) die in a scavenge instead of getting promoted into
    # old-space where only a major GC can collect them. With 30 GiB of RAM the
    # memory is free; the win is far fewer GC pauses in a client that keeps
    # weeks of message history live in the heap.
    # The inner quotes keep both V8 flags in one argv entry: makeWrapper splits
    # --add-flags on whitespace, and Chrome hands --js-flags to V8 verbatim.
    "--js-flags='--max-old-space-size=8192 --max-semi-space-size=64'"

    # Cache in RAM rather than on disk: a tmpfs-backed HTTP/code cache makes
    # avatars, emoji and Slack's own JS bundles reload without touching the
    # filesystem, and it is wiped on logout by design. Budget stays under a
    # third of the 3.1 GiB $XDG_RUNTIME_DIR so the rest of the session still
    # has room; the on-disk cache is ~1.2 GiB but most of that is cold blobs.
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
        --run 'SLACK_CACHE_DIR="''${XDG_RUNTIME_DIR:-/tmp}/slack-cache"; mkdir -p "$SLACK_CACHE_DIR"' \
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
