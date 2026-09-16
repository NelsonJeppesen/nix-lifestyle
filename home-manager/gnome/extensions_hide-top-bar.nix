{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/hidetopbar" = {
      enable-intellihide = true; # Only hide when a window needs the space
      mouse-sensitive = true; # Reveal the panel when the pointer hits the top edge
      show-in-overview = true; # Keep the panel visible in the Activities overview
    };
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.hide-top-bar;
    }
  ];
}
