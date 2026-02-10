# gnome-extensions.nix - GNOME Shell extensions and their dconf settings
#
# Installs and configures GNOME Shell extensions:
# - AppIndicator: system tray support for legacy apps
# - Bitcoin Markets: live BTC price ticker in the top bar
# - Caffeine: prevent screen blanking with a toggle (Super+O)
# - Clipboard Indicator: clipboard history manager (Ctrl+Shift+I to toggle)
# - Just Perfection: fine-tune GNOME Shell UI elements
# - Picture of the Day: wallpaper from Bing's daily image
# - Run-or-Raise: focus-or-launch apps via keyboard shortcuts
# - Quick Lofi: internet radio player with SomaFM stations
# - GitHub Notifications Redux: GitHub notification count in top bar
{ pkgs, gnome-github-notifications-redux, ... }:
{
  # Deploy run-or-raise shortcut configuration
  # This maps keyboard shortcuts to apps (focus if running, launch if not)
  home.file.".config/run-or-raise/shortcuts.conf".source = ./dotfiles/shortcuts.conf;

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.appindicator; } # System tray icons
      { package = pkgs.gnomeExtensions.bitcoin-markets; } # BTC price in top bar
      { package = pkgs.gnomeExtensions.caffeine; } # Inhibit screen blanking
      { package = pkgs.gnomeExtensions.clipboard-indicator; } # Clipboard history
      { package = pkgs.gnomeExtensions.just-perfection; } # UI customization tweaks
      { package = pkgs.gnomeExtensions.picture-of-the-day; } # Daily wallpaper
      { package = pkgs.gnomeExtensions.run-or-raise; } # Keyboard-driven app switching

      # Quick Lofi: play internet radio (SomaFM, etc.) from the GNOME top bar
      # Requires socat and mpv packages (installed in home.nix)
      #   https://github.com/eucaue/gnome-shell-extension-quick-lofi
      { package = pkgs.gnomeExtensions.quick-lofi; }

      # GitHub Notifications Redux: notification count in top bar with desktop alerts
      #   https://github.com/NelsonJeppesen/gnome-github-notifications-redux
      {
        id = "github-notifications-redux@jeppesen.io";
        package = gnome-github-notifications-redux.packages.${pkgs.system}.default;
      }
    ];
  };

  # ── Extension-specific dconf settings ─────────────────────────────
  dconf.settings = {

    # Just Perfection: customize GNOME Shell UI elements
    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = false; # Hide accessibility menu from top bar
      dash = false; # Hide the dock/dash
      search = true; # Keep search in Activities overview
      startup-status = 0; # Skip the Activities overview on login
      theme = false; # Don't apply extension's theme
      window-maximized-on-create = true; # Auto-maximize new windows
    };

    # Clipboard Indicator: clipboard history with keyboard shortcuts
    "org/gnome/shell/extensions/clipboard-indicator" = {
      cache-size = 10; # Number of items to persist across restarts
      clear-history = [ ];
      disable-down-arrow = true;
      display-mode = 1; # Compact display mode
      history-size = 200; # Total items to keep in history
      move-item-first = true; # Move selected item to top of history
      next-entry = [ "<Shift><Control>p" ]; # Next clipboard entry
      paste-button = false;
      prev-entry = [ "<Shift><Control>o" ]; # Previous clipboard entry
      private-mode-binding = [ ];
      strip-text = true; # Strip formatting when pasting
      toggle-menu = [ "<Shift><Control>i" ]; # Toggle clipboard menu
      topbar-preview-size = 9; # Characters shown in top bar preview
    };

    # Quick Lofi: internet radio player configuration
    # Pre-configured with all SomaFM channels for one-click streaming
    "org/gnome/shell/extensions/quick-lofi" = {
      volume = 75;
      set-popup-max-height = false;

      # SomaFM radio stations (all channels as of 2025-09-21)
      # SomaFM is a listener-supported internet radio service
      radios = [
        "SomaFM Beat Blender - https://api.somafm.com/beatblender130.pls"
        "SomaFM Black Rock FM - https://api.somafm.com/brfm130.pls"
        "SomaFM Boot Liquor - https://api.somafm.com/bootliquor130.pls"
        "SomaFM Bossa Beyond - https://api.somafm.com/bossa130.pls"
        "SomaFM Chillits Radio - https://api.somafm.com/chillits130.pls"
        "SomaFM cliqhop idm - https://api.somafm.com/cliqhop130.pls"
        "SomaFM Covers - https://api.somafm.com/covers130.pls"
        "SomaFM Deep Space One - https://api.somafm.com/deepspaceone130.pls"
        "SomaFM DEF CON Radio - https://api.somafm.com/defcon130.pls"
        "SomaFM Digitalis - https://api.somafm.com/digitalis130.pls"
        "SomaFM Doomed - https://api.somafm.com/doomed130.pls"
        "SomaFM Drone Zone - https://api.somafm.com/dronezone130.pls"
        "SomaFM Dub Step Beyond - https://api.somafm.com/dubstep130.pls"
        "SomaFM Fluid - https://api.somafm.com/fluid130.pls"
        "SomaFM Folk Forward - https://api.somafm.com/folkfwd130.pls"
        "SomaFM Groove Salad - https://api.somafm.com/groovesalad130.pls"
        "SomaFM Groove Salad Classic - https://api.somafm.com/gsclassic130.pls"
        "SomaFM Heavyweight Reggae - https://api.somafm.com/reggae130.pls"
        "SomaFM Illinois Street Lounge - https://api.somafm.com/illstreet130.pls"
        "SomaFM Indie Pop Rocks! - https://api.somafm.com/indiepop130.pls"
        "SomaFM Left Coast 70s - https://api.somafm.com/seventies130.pls"
        "SomaFM Live - https://api.somafm.com/live130.pls"
        "SomaFM Lush - https://api.somafm.com/lush130.pls"
        "SomaFM Metal Detector - https://api.somafm.com/metal130.pls"
        "SomaFM Mission Control - https://api.somafm.com/missioncontrol130.pls"
        "SomaFM n5MD Radio - https://api.somafm.com/n5md130.pls"
        "SomaFM PopTron - https://api.somafm.com/poptron130.pls"
        "SomaFM Secret Agent - https://api.somafm.com/secretagent130.pls"
        "SomaFM Seven Inch Soul - https://api.somafm.com/7soul130.pls"
        "SomaFM SF 10-33 - https://api.somafm.com/sf1033130.pls"
        "SomaFM SF in SF - https://api.somafm.com/sfinsf130.pls"
        "SomaFM SF Police Scanner - https://api.somafm.com/scanner130.pls"
        "SomaFM Sonic Universe - https://api.somafm.com/sonicuniverse130.pls"
        "SomaFM Space Station Soma - https://api.somafm.com/spacestation130.pls"
        "SomaFM Specials - https://api.somafm.com/specials130.pls"
        "SomaFM Suburbs of Goa - https://api.somafm.com/suburbsofgoa130.pls"
        "SomaFM Synphaera Radio - https://api.somafm.com/synphaera130.pls"
        "SomaFM The Dark Zone - https://api.somafm.com/darkzone130.pls"
        "SomaFM The In-Sound - https://api.somafm.com/insound130.pls"
        "SomaFM Tiki Time - https://api.somafm.com/tikitime130.pls"
        "SomaFM Vaporwaves - https://api.somafm.com/vaporwaves130.pls"
        "Fogpoint Radio - https://streaming.live365.com/a25002"
      ];
    };

    # Picture of the Day: set desktop wallpaper from Bing's daily image
    "org/gnome/shell/extensions/swsnr-picture-of-the-day" = {
      selected-source = "bing";
    };

    # AppIndicator: system tray icon appearance settings
    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = -0.1; # Slightly dimmed icons
      icon-opacity = 255; # Fully opaque
      icon-saturation = 0.8; # Slightly desaturated
      icon-size = 18; # Icon size in pixels
      tray-pos = "right"; # Position tray on the right side of top bar
    };

    # Caffeine: prevent screen blanking/screensaver activation
    "org/gnome/shell/extensions/caffeine" = {
      indicator-position = 17;
      indicator-position-index = 3;
      screen-blank = "never"; # Never blank screen when active
      show-indicator = "only-active"; # Only show icon when caffeine is on
      show-notifications = false; # Don't notify on toggle
      toggle-shortcut = [ "<Super>o" ]; # Super+O to toggle
    };
  };
}
