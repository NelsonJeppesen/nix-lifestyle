{
  pkgs,
  lib,
  gnome-github-notifications-redux,
  ...
}:
{
  # Application shortcuts.
  home.file.".config/run-or-raise/shortcuts.conf".source = ./dotfiles/shortcuts.conf;

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.bitcoin-markets; } # BTC/ETH prices in top bar
      { package = pkgs.gnomeExtensions.appindicator; } # System tray icons
      { package = pkgs.gnomeExtensions.blur-my-shell; }
      { package = pkgs.gnomeExtensions.caffeine; } # Inhibit screen blanking
      { package = pkgs.gnomeExtensions.clipboard-indicator; } # Clipboard history
      { package = pkgs.gnomeExtensions.disable-unredirect; } # Disable fullscreen unredirect (fixes Wayland hide-top-bar/overlay glitches)
      { package = pkgs.gnomeExtensions.draw-on-gnome; } # Draw/annotate on the screen
      { package = pkgs.gnomeExtensions.hide-top-bar; } # Auto-hide the top bar
      { package = pkgs.gnomeExtensions.just-perfection; } # UI customization tweaks
      { package = pkgs.gnomeExtensions.random-wallpaper; } # Rotating wallpaper from online sources
      { package = pkgs.gnomeExtensions.run-or-raise; } # Keyboard-driven app switching
      { package = pkgs.gnomeExtensions.unblank; } # Show wallpaper sharply on lock screen (no blur/dim)

      { package = pkgs.gnomeExtensions.quick-lofi; }

      # GitHub notifications.
      {
        id = "github-notifications-redux@jeppesen.io";
        package = gnome-github-notifications-redux.packages.${pkgs.stdenv.hostPlatform.system}.default;
      }
    ];
  };

  #  Extension-specific dconf settings
  dconf.settings = {

    # Just Perfection: customize GNOME Shell UI elements
    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = false; # Hide accessibility menu from top bar
      animation = 4;
      dash = false; # Hide the dock/dash
      quick-settings-do-not-disturb = false;
      search = true; # Keep search in Activities overview
      startup-status = 0; # Skip the Activities overview on login
      theme = false; # Don't apply extension's theme
      window-maximized-on-create = true; # Auto-maximize new windows
    };

    # Hide Top Bar: auto-hide the panel; reveal it in the overview, when the
    # pointer hits the top edge, or (intellihide) when no window needs the space.
    "org/gnome/shell/extensions/hidetopbar" = {
      enable-intellihide = true; # Only hide when a window needs the space
      mouse-sensitive = true; # Reveal the panel when the pointer hits the top edge
      show-in-overview = true; # Keep the panel visible in the Activities overview
    };

    # Clipboard history; shortcuts disabled.
    "org/gnome/shell/extensions/clipboard-indicator" = {
      blink-icon-on-copy = true;
      cache-size = 10; # Number of items to persist across restarts
      clear-history = [ ];
      disable-down-arrow = true;
      display-mode = 1; # Compact display mode
      history-size = 200; # Total items to keep in history
      move-item-first = true; # Move selected item to top of history
      next-entry = [ ]; # Unbound: <Shift><Control> chords belong to herdr (herdr.nix)
      notify-on-copy = false;
      open-at-cursor = true;
      paste-button = false;
      paste-on-select = false;
      prev-entry = [ ]; # Unbound: <Shift><Control> chords belong to herdr (herdr.nix)
      preview-size = 45;
      private-mode-binding = [ ];
      show-clear-history-button = false;
      show-delete-button = false;
      show-preview-button = false;
      show-private-mode = false;
      show-settings-button = false;
      show-tag-button = false;
      strip-text = true; # Strip formatting when pasting
      toggle-menu = [ ]; # Unbound: <Shift><Control> chords belong to herdr (herdr.nix)
      topbar-preview-size = 9; # Characters shown in top bar preview
    };

    # Quick Lofi: selected SomaFM genres for one-click streaming
    "org/gnome/shell/extensions/quick-lofi" = {
      volume = 75;
      set-popup-max-height = false;
      enable-mini-player = false;
      enable-mpris = false;

      indicator-actions = [
        "showPopupMenu"
        "playPause"
        "stopPlayer"
      ];

      radios = [
        "SomaFM Ambient Dark Zone - https://api.somafm.com/darkzone130.pls"
        "SomaFM Ambient Deep Space One - https://api.somafm.com/deepspaceone130.pls"
        "SomaFM Ambient Doomed - https://api.somafm.com/doomed130.pls"
        "SomaFM Ambient Drone Zone - https://api.somafm.com/dronezone130.pls"
        "SomaFM Ambient Drone Zone 2 - https://api.somafm.com/dz2130.pls"
        "SomaFM Ambient Groove Salad - https://api.somafm.com/groovesalad130.pls"
        "SomaFM Ambient Groove Salad 2 - https://api.somafm.com/groovesalad2130.pls"
        "SomaFM Ambient Groove Salad Classic - https://api.somafm.com/gsclassic130.pls"
        "SomaFM Ambient Mission Control - https://api.somafm.com/missioncontrol130.pls"
        "SomaFM Ambient SF 10-33 - https://api.somafm.com/sf1033130.pls"
        "SomaFM Ambient Synphaera Radio - https://api.somafm.com/synphaera130.pls"

        "SomaFM Americana Boot Liquor - https://api.somafm.com/bootliquor130.pls"

        "SomaFM Electronic Beat Blender - https://api.somafm.com/beatblender130.pls"
        "SomaFM Electronic cliqhop idm - https://api.somafm.com/cliqhop130.pls"
        "SomaFM Electronic DEF CON Radio - https://api.somafm.com/defcon130.pls"
        "SomaFM Electronic Digitalis - https://api.somafm.com/digitalis130.pls"
        "SomaFM Electronic Dub Step Beyond - https://api.somafm.com/dubstep130.pls"
        "SomaFM Electronic Fluid - https://api.somafm.com/fluid130.pls"
        "SomaFM Electronic Lush - https://api.somafm.com/lush130.pls"
        "SomaFM Electronic Space Station Soma - https://api.somafm.com/spacestation130.pls"
        "SomaFM Electronic The Trip - https://api.somafm.com/thetrip130.pls"
        "SomaFM Electronic Underground 80s - https://api.somafm.com/u80s130.pls"
        "SomaFM Electronic Vaporwaves - https://api.somafm.com/vaporwaves130.pls"

        "SomaFM Spoken SF in SF - https://api.somafm.com/sfinsf130.pls"
      ];
    };

    # Chatbot panel colors.
    "org/gnome/shell/extensions/penguin-ai-chatbot" = {
      human-message-color = "rgb(213,97,153)";
      human-message-text-color = "rgb(255,255,255)";
      llm-message-color = "rgb(54,54,58)";
      llm-message-text-color = "rgb(255,255,255)";
      llm-provider = "openai";
      openai-model = "gpt-5.5";
    };

    # AppIndicator: system tray icon appearance settings
    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = -0.1; # Slightly dimmed icons
      icon-opacity = 255; # Fully opaque
      icon-saturation = 0.8; # Slightly desaturated
      icon-size = 18; # Icon size in pixels
      tray-pos = "right"; # Position tray on the right side of top bar
    };

    # Unblank: keep wallpaper visible on lock screen instead of blanking
    "org/gnome/shell/extensions/unblank" = {
      power = true; # Keep unblank behavior active on battery/AC
      time = 1800; # Seconds before screen blanks (30 minutes)
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

    # Blur pipelines.
    "org/gnome/shell/extensions/blur-my-shell" =
      let
        g = lib.hm.gvariant;
        # An a{sv} attribute dict: list of dictionary entries, value side variant-wrapped.
        mkAsv =
          attrs:
          g.mkArray
            (g.type.dictionaryEntryOf [
              g.type.string
              g.type.variant
            ])
            (
              lib.mapAttrsToList (
                k: v:
                g.mkDictionaryEntry [
                  k
                  (g.mkVariant v)
                ]
              ) attrs
            );
        # A single effect entry: a{sv} dict with type/id/params keys.
        mkEffect =
          {
            type,
            id,
            params,
          }:
          mkAsv {
            inherit type id;
            params = mkAsv params;
          };
        # A pipeline: a{sv} dict with name + effects (av).
        mkPipeline =
          { name, effects }:
          mkAsv {
            inherit name;
            effects = g.mkArray g.type.variant (map (e: g.mkVariant (mkEffect e)) effects);
          };
        # Outer a{sa{sv}}: list of dict entries keyed by pipeline id, value is the pipeline a{sv}.
        pipelinesValue =
          g.mkArray
            (g.type.dictionaryEntryOf [
              g.type.string
              (g.type.arrayOf (
                g.type.dictionaryEntryOf [
                  g.type.string
                  g.type.variant
                ]
              ))
            ])
            (
              lib.mapAttrsToList
                (
                  k: v:
                  g.mkDictionaryEntry [
                    k
                    (mkPipeline v)
                  ]
                )
                {
                  pipeline_default = {
                    name = "Default";
                    effects = [
                      {
                        type = "native_static_gaussian_blur";
                        id = "effect_000000000000";
                        params = {
                          radius = 30;
                          brightness = g.mkDouble 0.6;
                        };
                      }
                    ];
                  };
                  pipeline_default_rounded = {
                    name = "Default rounded";
                    effects = [
                      {
                        type = "native_static_gaussian_blur";
                        id = "effect_000000000001";
                        params = {
                          radius = 30;
                          brightness = g.mkDouble 0.6;
                        };
                      }
                      {
                        type = "corner";
                        id = "effect_000000000002";
                        params = {
                          radius = 24;
                        };
                      }
                    ];
                  };
                  # Disable lock-screen blur.
                  pipeline_03754227297483 = {
                    name = "nothing";
                    effects = [ ];
                  };
                }
            );
      in
      {
        settings-version = 2;
        pipelines = pipelinesValue;
      };

    # Wallpaper rotation.
    "org/gnome/shell/extensions/space-iflow-randomwallpaper" = {
      auto-fetch = true;
      change-lock-screen = false;
      disable-hover-preview = true;
      fetch-on-startup = true;
      hide-panel-icon = true;
      hours = 24;
      sources = [ "forest" ];
    };
    "org/gnome/shell/extensions/space-iflow-randomwallpaper/backend-connection" = {
      backend-connection-available = true;
      clear-history = false;
      open-folder = false;
      pause-timer = false;
      request-new-wallpaper = false;
    };

    "org/gnome/shell/extensions/space-iflow-randomwallpaper/sources/general/forest" = {
      type = 1;
      name = "forest";
    };
    "org/gnome/shell/extensions/space-iflow-randomwallpaper/sources/wallhaven/forest" = {
      keyword = "forest";
      color = "336600"; # #336600
      minimal-resolution = "2560x1600";
    };

    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      blur = true;
      pipeline = "pipeline_03754227297483";
    };

    # Disable blur on all other surfaces; only the lock screen hook is used
    # (and even that routes through the empty pipeline).
    "org/gnome/shell/extensions/blur-my-shell/panel".blur = false;
    "org/gnome/shell/extensions/blur-my-shell/overview".blur = false;
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock".blur = false;
    "org/gnome/shell/extensions/blur-my-shell/screenshot".blur = false;
    "org/gnome/shell/extensions/blur-my-shell/window-list".blur = false;
    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab".blur = false;
  };
}
