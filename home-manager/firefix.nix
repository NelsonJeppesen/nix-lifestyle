{ config, pkgs, ... }:
{

  programs.firefox = {
    enable = true;
    profiles = {
      home = {
        id = 0;
        name = "home";
        # Hide tab bar and side bar header
        userChrome = "\n          #TabsToolbar\n          { visibility: collapse; }\n          #sidebar-box #sidebar-header {\n            display: none !important;\n          }\n        ";
        settings = {
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "layout.css.backdrop-filter.enabled" = true;
          "svg.context-properties.content.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        search = {
          default = "o4mini"; # Change this to your desired engine
          force = true;

          engines = {
            google.metaData.alias = "g";
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
