# Keep fullscreen windows composited; this trades direct scanout for consistency.
{ pkgs, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.disable-unredirect;
    }
  ];
}
