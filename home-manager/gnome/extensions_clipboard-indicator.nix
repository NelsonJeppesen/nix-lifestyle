# Keep searchable clipboard history; copied text can persist in the local cache.
{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/clipboard-indicator" = {
      blink-icon-on-copy = true;
      cache-size = 10; # MiB threshold checked when reading the persistent cache
      clear-history = [ ];
      disable-down-arrow = true;
      display-mode = 1; # Display clipboard text in the top bar
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

  programs.gnome-shell.extensions = [
    {
      # nixpkgs packages clipboard-indicator v71, which calls
      # Clutter.get_default_backend() and sets St.BoxLayout:vertical; GNOME
      # Shell 51 removed both, so enable() throws and the panel icon never
      # appears. v72 ports it to GNOME 51
      # (https://github.com/Tudmotu/gnome-shell-extension-clipboard-indicator/pull/641).
      # Drop this override once pkgs.gnomeExtensions.clipboard-indicator is
      # v72 or later.
      package = pkgs.gnomeExtensions.clipboard-indicator.overrideAttrs {
        version = "72";
        src = pkgs.fetchzip {
          url = "https://extensions.gnome.org/extension-data/clipboard-indicatortudmotu.com.v72.shell-extension.zip";
          hash = "sha256-NX3JtWrehr1cbqG+JwK4V+qWs2if1tbFJHwXF+l5/Ww=";
          stripRoot = false;
        };
      };
    }
  ];
}
