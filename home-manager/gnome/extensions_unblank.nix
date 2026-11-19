# Extend screen-on time through Unblank when AC power is available.
{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/unblank" = {
      power = true; # Disable Unblank inhibition while running on battery
      time = 1800; # Seconds before screen blanks (30 minutes)
    };
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.unblank;
    }
  ];
}
