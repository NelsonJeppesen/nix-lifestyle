{ pkgs, ... }: {
  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.clipboard-indicator;
    }
  ];

  dconf.settings = {
    "org/gnome/shell/extensions/clipboard-indicator" = {
      blink-icon-on-copy = true;
      cache-size = 10; # Number of items to persist across restarts
      clear-history = [ ];
      disable-down-arrow = true;
      display-mode = 1; # Compact display mode
      history-size = 200; # Total items to keep in history
      move-item-first = true; # Move selected item to top of history
      next-entry = [ ]; # Unbound: <Shift><Control> chords belong to herdr (herdr.nix)
      notify-on-copy = false;
      open-at-cursor = true;
      paste-button = false;
      paste-on-select = false;
      prev-entry = [ ]; # Unbound: <Shift><Control> chords belong to herdr (herdr.nix)
      preview-size = 45;
      private-mode-binding = [ ];
      show-clear-history-button = false;
      show-delete-button = false;
      show-preview-button = false;
      show-private-mode = false;
      show-settings-button = false;
      show-tag-button = false;
      strip-text = true; # Strip formatting when pasting
      toggle-menu = [ ]; # Unbound: <Shift><Control> chords belong to herdr (herdr.nix)
      topbar-preview-size = 9; # Characters shown in top bar preview
    };
  };
}
