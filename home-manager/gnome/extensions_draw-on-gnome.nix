# Enable temporary on-screen drawing for explanations and presentations.
{ pkgs, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.draw-on-gnome;
    }
  ];
}
