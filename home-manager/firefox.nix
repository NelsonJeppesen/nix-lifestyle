{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles = {

      home = {
        id = 0;
        name = "home";
        # Hide tab bar and side bar header
        userChrome = "\n          #TabsToolbar\n          { visibility: collapse; }\n          #sidebar-box #sidebar-header {\n            display: none !important;\n          }\n        ";

        # Chrome-style auto suspend
        #extensions = with pkgs.firefox-addons; [
        #  auto-tab-discard
        #];

        settings = {
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
          #"network.prefetch-next" = false;
          #"network.dns.disablePrefetch" = true;
          #"network.predictor.enabled" = false;

          # ✅ Wayland niceties (harmless on X11; ignored)
          "widget.wayland.async-dnd" = true;
          "widget.use-xdg-desktop-portal.file-picker" = 1;
        };

        search = {
          default = "google"; # Change this to your desired engine
          force = true;

          engines = {
            bing.metaData.hidden = true;
            ebay.metaData.hidden = true;
            wikipedia.metaData.hidden = true;
            ddg.metaData.hidden = true;
            amazondotcom-us.metaData.hidden = true;

            "gmail" = {
              urls = [ { template = "https://mail.google.com/mail/u/0/#search/{searchTerms}"; } ];
              definedAliases = [ "gm" ];
            };

            "o3" = {
              urls = [ { template = "https://chatgpt.com/?model=o3&q={searchTerms}"; } ];
              definedAliases = [ "o3" ];
            };

            "o4mini" = {
              urls = [ { template = "https://chatgpt.com/?model=o4-mini&q={searchTerms}"; } ];
              definedAliases = [ "o4" ];
            };

            nix-packages = {
              name = "Nix Packages";
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "np" ];
            };
          };
        };
      };
    };
  };
}
