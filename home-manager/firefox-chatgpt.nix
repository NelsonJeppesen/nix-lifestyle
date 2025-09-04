{ pkgs, ... }:

let
  chatgpt-firefox = pkgs.writeShellScriptBin "chatgpt" ''
    #!/usr/bin/env bash
    exec ${pkgs.firefox}/bin/firefox \
      --no-remote     \
      --new-instance  \
      --P chatgpt       \
      --class chatgpt   \
      --name chatgpt    \
      --new-window "https://chatgpt.com/" "$@"
  '';
in
{
  home.packages = [ chatgpt-firefox ];

  programs.firefox = {
    enable = true;
    profiles = {

      chatgpt = {
        id = 2;

        # Enable userChrome.css and keep system titlebar (so you have close/min/max)
        settings = {
          # Startup
          "browser.startup.page" = 1;
          "browser.startup.homepage" = "https://chatgpt.com/";
          "browser.sessionstore.resume_from_crash" = false;
          "browser.sessionstore.resume_session_once" = false;
          "browser.sessionstore.max_resumed_crashes" = -1;
          "browser.sessionstore.restore_on_demand" = false;
          "browser.sessionstore.restore_pinned_tabs_on_demand" = false;

          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "layout.css.backdrop-filter.enabled" = true;
          "svg.context-properties.content.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # 🔧 Background Tab Throttling
          "dom.min_background_timeout_value" = 1000;
          "dom.timeout.enable_budget_timer_throttling" = true;
          "dom.timeout.background_throttling_max_budget" = 50;
          "dom.ipc.processPriorityManager.enabled" = true;

          # 🌙 Sleep Background Tabs
          "browser.tabs.unloadOnLowMemory" = true;
          "browser.tabs.unloadOnLowMemory.delay_ms" = 60000;

          # 🎨 Rendering (lower paints when idle; Wayland compositor path)
          "layout.frame_rate" = 30;
          "gfx.webrender.compositor.force-enabled" = true;

          # 💤 Kill wasteful background fetches
          "network.prefetch-next" = false;
          "network.dns.disablePrefetch" = true;
          "network.predictor.enabled" = false;
        };

        # Kill all browser chrome
        userChrome = ''
          /* Tabs + toolbars */
          #TabsToolbar, #tabbrowser-tabs, .tabbrowser-tab { display:none !important; }
          #nav-bar, #toolbar-menubar, #PersonalToolbar {
            visibility: collapse !important; height:0 !important; padding:0 !important; margin:0 !important; border:0 !important;
          }
          #sidebar-box { display:none !important; }

          /* Content area flush */
          #browser, #appcontent { margin:0 !important; padding:0 !important; }
          :root { scrollbar-width: thin !important; }
        '';
      };
    };
  };
}
