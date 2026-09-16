{ pkgs, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.disable-unredirect;
    }
  ];
}
