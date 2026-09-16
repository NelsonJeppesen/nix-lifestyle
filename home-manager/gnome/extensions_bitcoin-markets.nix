{ pkgs, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.bitcoin-markets;
    }
  ];
}
