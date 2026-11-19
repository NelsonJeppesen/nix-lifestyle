# Configure Chrome for Wayland while retaining Chromium resource-management defaults.
{ pkgs, lib, ... }:
let
  # Chromium feature flags. Chrome stores --enable-features in a switch map, so
  # a second copy of the switch would silently replace the first -- everything
  # has to go in this one list.
  chromeFeatures = lib.concatStringsSep "," [
    "VaapiVideoEncoder"
    "VaapiVideoDecoder"
    "WaylandWindowDecorations"

  ];
in
{
  programs.google-chrome = {
    enable = true;
    package = pkgs.google-chrome;

    # These flags apply to regular browser windows and affect battery use.
    commandLineArgs = [
      "--no-default-browser-check"
      "--password-store=basic" # Bypass the desktop keyring; not secret-store-backed

      # Wayland and GPU acceleration.
      "--ozone-platform=wayland"
      "--use-angle=gl"
      "--ignore-gpu-blocklist"
      "--enable-features=${chromeFeatures}"

      # Enable GPU rasterization and zero-copy.
      "--enable-gpu-rasterization"
      "--enable-zero-copy"

      # Chromium owns background scheduling, cache retention, and prefetch
      # budgets so hidden tabs can yield resources to active work.
    ];

    # GNOME desktop, not Plasma
    plasmaSupport = false;
  };
}
