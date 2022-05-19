{ config, lib, pkgs, ... }:
{
  home.packages = [
    #pkgs.gnomeExtensions.gsconnect
    pkgs.gnome3.gpaste
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.material-shell
    pkgs.gnomeExtensions.run-or-raise
    pkgs.gnomeExtensions.github-notifications
  ];

  home.file.".config/run-or-raise/shortcuts.conf".source = ../dotfiles/shortcuts.conf;

  dconf.settings = {

    # Use capslock as super key
    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "caps:super" # map capslock to windows/mac key
        "numpad:mac" # always enable numlock
        "f:XF86AudioRaiseVolume"
      ];
    };

    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "GPaste@gnome-shell-extensions.gnome.org" # clipboard manager with img support
        "appindicatorsupport@rgcjonas.gmail.com" # show notifications e.g. slack
        "caffeine@patapon.info" # top bar icon to prevent sleep
        "run-or-raise@edvard.cz"
      ];
    };

    "org/gnome/shell/extensions/appindicator" = {
      tray-pos = "center";
    };

    "org/gnome/GPaste" = {
      images-support = true;
      max-history-size = lib.hm.gvariant.mkUint64 2000;
      max-memory-usage = lib.hm.gvariant.mkUint64 100;
      trim-items = true;
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/shell/extensions/caffeine" = {
      show-notifications = false;
      user-enabled = false;
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ ]; # Free up <Super>space
      switch-input-source-backward = [ ]; # Free up <Super><Shift>space
      toggle-message-tray = [ ]; # Free up <Super>m
      close = [ "<Super>BackSpace" ];
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_R";
    };

    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
    };

    # map the mappings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      next = [ "<Super>bracketright" ];
      previous = [ "<Super>bracketleft" ];
      volume-down = [ "<Shift><Super>braceleft" ];
      volume-up = [ "<Shift><Super>braceright" ];
      search = [ "<Super>space" ];
    };

    "org/gnome/mutter" = {
      # active screen edge. Drag windows to edge of screen to resize
      edge-tiling = true;
    };
  };
}
