{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/unblank" = {
      power = true; # Keep unblank behavior active on battery/AC
      time = 1800; # Seconds before screen blanks (30 minutes)
    };
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.unblank;
    }
  ];
}
