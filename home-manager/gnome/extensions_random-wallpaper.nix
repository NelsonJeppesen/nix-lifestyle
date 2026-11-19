# Rotate forest wallpapers about once a day; the lock screen keeps its own wallpaper.
{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/space-iflow-randomwallpaper" = {
      auto-fetch = true;
      change-type = 0; # Desktop background only
      disable-hover-preview = true;
      fetch-on-startup = true;
      hide-panel-icon = true;
      # Rotation interval; the schema caps hours at 23 and minutes at 59, and an
      # out-of-range value silently falls back to the 1 h 30 min default.
      hours = 23;
      minutes = 59;
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
  };

  programs.gnome-shell.extensions = [
    {
      # nixpkgs packages random-wallpaper v39 (3.2.0), which sets
      # St.BoxLayout:vertical in its panel menu; GNOME Shell 51 removed that
      # property, so enable() throws and the extension stays in ERROR. Drop
      # this patch once pkgs.gnomeExtensions.random-wallpaper lists shell
      # version 51 in its metadata.json.
      package = pkgs.gnomeExtensions.random-wallpaper.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace historyMenuElements.js \
            --replace-fail "vertical: true," "orientation: Clutter.Orientation.VERTICAL,"
        '';
      });
    }
  ];
}
