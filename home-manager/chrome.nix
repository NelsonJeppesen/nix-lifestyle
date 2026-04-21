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
      "--ozone-platform=wayland"
      "--use-gl=egl"
      "--ignore-gpu-blocklist"
      "--enable-features=VaapiVideoEncoder,VaapiVideoDecoder,WaylandWindowDecorations"

      # Battery (less aggressive than the per-PWA wrappers; full browser still
      # needs background networking for normal tabs)
      "--disable-backgrounding-occluded-windows"
    ];

    # GNOME desktop, not Plasma
    plasmaSupport = false;

    # Native messaging hosts (browserpass, plasma-browser-integration, etc.)
    nativeMessagingHosts = [ ];
  };
}
