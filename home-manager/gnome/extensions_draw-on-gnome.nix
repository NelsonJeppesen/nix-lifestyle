{ pkgs, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.draw-on-gnome;
    }
  ];
}
