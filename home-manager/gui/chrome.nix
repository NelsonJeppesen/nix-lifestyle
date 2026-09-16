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

      # Battery (less aggressive than the per-PWA wrappers; full browser still
      # needs background networking for normal tabs)
      "--disable-backgrounding-occluded-windows"
    ];

    # GNOME desktop, not Plasma
    plasmaSupport = false;
  };
}
