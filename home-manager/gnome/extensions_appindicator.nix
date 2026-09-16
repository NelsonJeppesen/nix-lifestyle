{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = -0.1; # Slightly dimmed icons
      icon-opacity = 255; # Fully opaque
      icon-saturation = 0.8; # Slightly desaturated
      icon-size = 18; # Icon size in pixels
      tray-pos = "right"; # Position tray on the right side of top bar
    };
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.appindicator;
    }
  ];
}
