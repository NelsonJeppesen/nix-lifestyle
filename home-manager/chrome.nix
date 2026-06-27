# chrome.nix - Google Chrome browser configuration
#
# Configures Chrome via home-manager's `programs.google-chrome` module:
# - Wrapped command-line flags for Wayland, VAAPI, and password-store opt-out
# - GNOME desktop (no Plasma integration)
#
# NOTE: home-manager removed `extensions` and `dictionaries` from
# `programs.google-chrome` (HM issue #1383): proprietary Chrome ignores the
# `External Extensions/<id>.json` mechanism. Declarative extensions and
# telemetry hardening live in Chrome's managed-policies file, configured at
# the NixOS layer in `nixos/profiles/chrome-policies.nix`.
#
# Per-PWA Chrome wrappers live in `chrome-apps.nix` and intentionally bypass
# this module to keep PWA flags isolated from the main browser.
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

      # Wayland / GPU
      # Chrome 147 removed the direct `--use-gl=egl` backend; only ANGLE-mediated
      # backends remain. Without an ANGLE selection the GPU process crashes on
      # boot and the whole pipeline (compositing, raster, video decode) falls
      # back to software. `--use-angle=gl` is the only ANGLE backend currently
      # compatible with `--ozone-platform=wayland` (vulkan errors out with
      # "not compatible with Vulkan"); it routes through Mesa's iris driver
      # and re-enables hardware compositing + VAAPI video decode.
      "--ozone-platform=wayland"
      "--use-angle=gl"
      "--ignore-gpu-blocklist"
      "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder,WaylandWindowDecorations"

      # Pin GPU rasterization + zero-copy. Chrome usually auto-enables these,
      # but on the forced ANGLE-GL path (above) the heuristic can fall back to
      # software raster; pinning them keeps scrolling/compositing on the iGPU
      # and uploads textures without a CPU copy. Verify at chrome://gpu.
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
