{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/caffeine" = {
      indicator-position = 17;
      indicator-position-index = 3;
      screen-blank = "never"; # Never blank screen when active
      show-indicator = "only-active"; # Only show icon when caffeine is on
      show-notifications = false; # Don't notify on toggle
      toggle-shortcut = [ "<Super>o" ]; # Super+O to toggle
    };
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.caffeine;
    }
  ];
}
