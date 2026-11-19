# Bind application keys to focus an existing window or start the application.
{ pkgs, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.run-or-raise;
    }
  ];

  home.file.".config/run-or-raise/shortcuts.conf".source = ./dotfiles/shortcuts.conf;
}
