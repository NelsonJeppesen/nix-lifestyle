{ pkgs, gnome-github-notifications-redux, ... }: {
  programs.gnome-shell.extensions = [
    {
      id = "github-notifications-redux@jeppesen.io";
      package = gnome-github-notifications-redux.packages.${pkgs.stdenv.hostPlatform.system}.default;
    }
  ];
}
