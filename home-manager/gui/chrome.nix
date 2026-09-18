{ pkgs, ... }:
{
  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome;

    # Command-line flags (mirrors the battery/Wayland tuning in chrome-apps.nix,
    # minus the PWA-only switches like --app= and --user-data-dir=).
    commandLineArgs = [
      "--no-default-browser-check"
      "--password-store=basic" # don't prompt for kwallet/gnome-keyring

      # Wayland and GPU acceleration.
      "--ozone-platform=wayland"
      "--use-angle=gl"
      "--ignore-gpu-blocklist"
      "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder,WaylandWindowDecorations"

      # Enable GPU rasterization and zero-copy.
      "--enable-gpu-rasterization"
      "--enable-zero-copy"

      # Keep background work at full speed rather than saving power. Pairs with
      # the IntensiveWakeUpThrottlingEnabled=false policy in chrome-policies.nix:
      # background tabs keep normal renderer priority and un-throttled timers,
      # so switching back to one is instant instead of janky.
      "--disable-backgrounding-occluded-windows"
      "--disable-renderer-backgrounding"
      "--disable-background-timer-throttling"
    ];

    # GNOME desktop, not Plasma
    plasmaSupport = false;
  };
}
