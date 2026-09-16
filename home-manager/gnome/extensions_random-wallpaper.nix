{ pkgs, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.random-wallpaper;
    }
  ];

  dconf.settings = {
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
  };
}
