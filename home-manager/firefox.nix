# firefox.nix - Firefox browser configuration
#
# Configures Firefox with:
# - Hidden tab bar (using a sidebar tab extension instead)
# - Hardware acceleration and WebRender enabled for Wayland
# - Background tab throttling and memory management
# - Custom search engines: Gmail, ChatGPT (o3/o4-mini), Nix Packages
# - Default built-in search engines hidden (Bing, eBay, Wikipedia, etc.)
{ pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    profiles = {

      # Default profile
      home = {
        id = 0;
        name = "home";

        # Hide the tab bar via userChrome CSS
        # A sidebar tab extension (e.g., Tree Style Tab) is used instead
        # for vertical tab management
        userChrome = "\n          #TabsToolbar\n          { visibility: collapse; }\n          #sidebar-box #sidebar-header {\n            display: none !important;\n          }\n        ";

        # Chrome-style auto suspend (disabled, using native Firefox instead)
        #extensions = with pkgs.firefox-addons; [
        #  auto-tab-discard
        #];

        settings = {
          # ── GPU acceleration and rendering ──────────────────────
          "gfx.webrender.all" = true; # Enable WebRender for all content
          "gfx.webrender.enabled" = true;
          "layers.acceleration.force-enabled" = true; # Force GPU layer acceleration
          "layout.css.backdrop-filter.enabled" = true; # Enable CSS backdrop-filter
          "svg.context-properties.content.enabled" = true; # SVG context properties
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # Enable userChrome.css

          # ── Background tab throttling ───────────────────────────
          # Reduce CPU/battery usage from inactive tabs
          "dom.min_background_timeout_value" = 1000; # Min timer interval for background tabs (ms)
          "dom.timeout.enable_budget_timer_throttling" = true;
          "dom.timeout.background_throttling_max_budget" = 50; # Budget per background tab (ms)
          "dom.ipc.processPriorityManager.enabled" = true; # Lower priority for background processes

          # ── Sleep/unload background tabs ────────────────────────
          # Automatically unload tabs when memory is low
          "browser.tabs.unloadOnLowMemory" = true;
          "browser.tabs.unloadOnLowMemory.delay_ms" = 60000; # Wait 60s before unloading

          # ── Rendering performance ───────────────────────────────
          # Lower frame rate when idle to save power (Wayland compositor path)
          "layout.frame_rate" = 30;
          "gfx.webrender.compositor.force-enabled" = true;

          # ── Disable prefetching (saves bandwidth, disabled for now) ──
          #"network.prefetch-next" = false;
          #"network.dns.disablePrefetch" = true;
          #"network.predictor.enabled" = false;

          # ── Wayland integration ─────────────────────────────────
          "widget.wayland.async-dnd" = true; # Async drag-and-drop on Wayland
          "widget.use-xdg-desktop-portal.file-picker" = 1; # Use native GNOME file picker
        };

        # ── Custom search engines ─────────────────────────────────
        search = {
          default = "google";
          force = true; # Override any profile search settings

          engines = {
            # Hide default search engines that are never used
            bing.metaData.hidden = true;
            ebay.metaData.hidden = true;
            wikipedia.metaData.hidden = true;
            ddg.metaData.hidden = true;
            amazondotcom-us.metaData.hidden = true;

            # Gmail search: type "gm <query>" in the address bar
            "gmail" = {
              urls = [ { template = "https://mail.google.com/mail/u/0/#search/{searchTerms}"; } ];
              definedAliases = [ "gm" ];
            };

            # ChatGPT o3: type "o3 <query>" for o3 model
            "o3" = {
              urls = [ { template = "https://chatgpt.com/?model=o3&q={searchTerms}"; } ];
              definedAliases = [ "o3" ];
            };

            # ChatGPT o4-mini: type "o4 <query>" for o4-mini model
            "o4mini" = {
              urls = [ { template = "https://chatgpt.com/?model=o4-mini&q={searchTerms}"; } ];
              definedAliases = [ "o4" ];
            };

            # Nix Packages search: type "np <package>" to search nixpkgs unstable
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
