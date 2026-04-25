# gnome-extensions.nix - GNOME Shell extensions and their dconf settings
#
# Installs and configures GNOME Shell extensions:
# - AppIndicator: system tray support for legacy apps
# - Bitcoin Markets: live BTC price ticker in the top bar
# - Caffeine: prevent screen blanking with a toggle (Super+O)
# - Clipboard Indicator: clipboard history manager (Ctrl+Shift+I to toggle)
# - Just Perfection: fine-tune GNOME Shell UI elements
# - Overview Calculator: inline calculator in the Activities overview
# - Picture of the Day: daily-rotating wallpaper (Stålenhag, Bing, APOD, …)
# - Run-or-Raise: focus-or-launch apps via keyboard shortcuts
# - Quick Lofi: internet radio player with SomaFM stations
# - SoundBar: real-time audio visualizer in the top bar (requires cava)
# - Tailscale Status: Tailscale VPN status indicator in top bar
# - GitHub Notifications Redux: GitHub notification count in top bar
{
  pkgs,
  lib,
  gnome-github-notifications-redux,
  ...
}:
{
  # Deploy run-or-raise shortcut configuration
  # This maps keyboard shortcuts to apps (focus if running, launch if not)
  home.file.".config/run-or-raise/shortcuts.conf".source = ./dotfiles/shortcuts.conf;

  programs.gnome-shell = {
    enable = true;
    extensions = [
      # { package = pkgs.gnomeExtensions.bitcoin-markets; } # BTC price in top bar
      { package = pkgs.gnomeExtensions.dynamic-music-pill; } # System tray icons
      { package = pkgs.gnomeExtensions.blur-my-shell; }

      { package = pkgs.gnomeExtensions.appindicator; } # System tray icons
      { package = pkgs.gnomeExtensions.caffeine; } # Inhibit screen blanking
      { package = pkgs.gnomeExtensions.clipboard-indicator; } # Clipboard history
      { package = pkgs.gnomeExtensions.just-perfection; } # UI customization tweaks
      { package = pkgs.gnomeExtensions.overview-calculator; } # Calculator in Activities overview
      { package = pkgs.gnomeExtensions.picture-of-the-day; } # Daily wallpaper
      { package = pkgs.gnomeExtensions.run-or-raise; } # Keyboard-driven app switching
      { package = pkgs.gnomeExtensions.unblank; } # Show wallpaper sharply on lock screen (no blur/dim)

      # Tailscale Status, patched so runtime toggles use `tailscale set`
      # instead of `tailscale up --reset`. With `services.tailscale.extraSetFlags
      # = [ "--operator=nelson" ]`, `set` works as the unprivileged user; the
      # original `up --reset` flow drops the operator and falls back to
      # `pkexec`, which is what triggers the constant root prompts when
      # changing exit nodes / shields / accept-routes from the top bar.
      # Also skip `--login-server=` for `set` commands (it's not a valid flag
      # for `tailscale set` and would cause the call to fail → pkexec retry).
      {
        package = pkgs.gnomeExtensions.tailscale-status.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace extension.js \
              --replace-fail \
                'cmdTailscale({ args: ["up", "--exit-node=" + node.address, "--reset"] })' \
                'cmdTailscale({ args: ["set", "--exit-node=" + node.address], addLoginServer: false })' \
              --replace-fail \
                'cmdTailscale({ args: ["up", "--exit-node=", "--reset"] });' \
                'cmdTailscale({ args: ["set", "--exit-node="], addLoginServer: false });' \
              --replace-fail \
                'cmdTailscale({ args: ["up", "--shields-up"] });' \
                'cmdTailscale({ args: ["set", "--shields-up=true"], addLoginServer: false });' \
              --replace-fail \
                'cmdTailscale({ args: ["up", "--shields-up=false", "--reset"] });' \
                'cmdTailscale({ args: ["set", "--shields-up=false"], addLoginServer: false });' \
              --replace-fail \
                'cmdTailscale({ args: ["up", "--accept-routes"] });' \
                'cmdTailscale({ args: ["set", "--accept-routes=true"], addLoginServer: false });' \
              --replace-fail \
                'cmdTailscale({ args: ["up", "--accept-routes=false", "--reset"] });' \
                'cmdTailscale({ args: ["set", "--accept-routes=false"], addLoginServer: false });' \
              --replace-fail \
                'cmdTailscale({ args: ["up", "--exit-node-allow-lan-access"] });' \
                'cmdTailscale({ args: ["set", "--exit-node-allow-lan-access=true"], addLoginServer: false });' \
              --replace-fail \
                'cmdTailscale({ args: ["up", "--exit-node-allow-lan-access=false", "--reset"] });' \
                'cmdTailscale({ args: ["set", "--exit-node-allow-lan-access=false"], addLoginServer: false });'
          '';
        });
      }

      # Quick Lofi: play internet radio (SomaFM, etc.) from the GNOME top bar
      # Requires socat and mpv packages (installed in home.nix)
      #   https://github.com/eucaue/gnome-shell-extension-quick-lofi
      { package = pkgs.gnomeExtensions.quick-lofi; }

      # GitHub Notifications Redux: notification count in top bar with desktop alerts
      #   https://github.com/NelsonJeppesen/gnome-github-notifications-redux
      {
        id = "github-notifications-redux@jeppesen.io";
        package = gnome-github-notifications-redux.packages.${pkgs.stdenv.hostPlatform.system}.default;
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

    # Picture of the Day: set desktop wallpaper from a daily-rotating source.
    # Currently set to Simon Stålenhag artwork; see extension for other sources
    # (bing, apod, wikimedia, etc.).
    "org/gnome/shell/extensions/swsnr-picture-of-the-day" = {
      selected-source = "stalenhag";
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

    # Blur My Shell: define reusable blur "pipelines" and apply one to the
    # lock screen. The `pipelines` schema is a deeply-nested gvariant
    # (a{sa{sv}} with `av` effects whose `params` are `a{sv}`), so we build
    # it explicitly with lib.hm.gvariant helpers.
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
                  # Empty pipeline used by the lock screen to disable blur entirely
                  # while still letting the extension be enabled elsewhere.
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

    # Lock screen: enable Blur My Shell hook but route through the empty
    # "nothing" pipeline so the lock screen stays sharp (paired with the
    # `unblank` extension above).
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
