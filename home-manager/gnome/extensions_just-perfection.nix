{ pkgs, ... }: {
  dconf.settings = {
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
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.just-perfection;
    }
  ];
}
