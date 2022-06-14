{ config, lib, pkgs, ... }:
{
  home.file.".config/run-or-raise/shortcuts.conf".source = ../dotfiles/shortcuts.conf;

  home.packages = [
    pkgs.gnome3.gpaste
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.bluetooth-battery
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.ddterm
    pkgs.gnomeExtensions.github-notifications
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.run-or-raise
    pkgs.gnomeExtensions.spotify-tray

    #pkgs.gnomeExtensions.somafm-internet-radio
    #pkgs.gnomeExtensions.taskwhisperer
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      disable-user-extensions = false;
      enabled-extensions = [
        "GPaste@gnome-shell-extensions.gnome.org" # gpaste
        "appindicatorsupport@rgcjonas.gmail.com" # appindicator
        "caffeine@patapon.info" # caffeine
        "github.notifications@alexandre.dufournet.gmail.com" #github-notifications
        "run-or-raise@edvard.cz" # run-or-raise
        "ddterm@amezin.github.com" # ddterm drop down term
        "sp-tray@sp-tray.esenliyim.github.com" # spotify-tray
      ];
    };

    "com/github/amezin/ddterm" = {
      background-color = "rgb(0x17, 0x14, 0x21)";
      background-opacity = 1.0;
      bold-is-bright = false;
      custom-font = "Hasklug Nerd Font 14";
      ddterm-toggle-hotkey = ["<Super>t"];
      foreground-color = "rgb(0xd0, 0xcf, 0xcc)";
      hide-when-focus-lost = true;
      override-window-animation = true;
      theme-variant = "light";
      use-system-font = false;
      use-theme-colors = false;
      window-maximize = false;
      window-size = 0.5;
    };

    "org/gnome/shell/extensions/github-notifications" = {
      handle = "NelsonJeppesen";
      hide-widget = true;
      refresh-interval = 61;
    };

    # Use capslock as super key
    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "caps:super" # map capslock to windows/mac key
        "numpad:mac" # always enable numlock
        "f:XF86AudioRaiseVolume"
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
      play = [ "<Super>backslash" ];
      previous = [ "<Super>bracketleft" ];

      search = [ "<Super>space" ];

      volume-down = [ "<Shift><Super>braceleft" ];
      volume-up = [ "<Shift><Super>braceright" ];
    };

    "org/gnome/mutter" = {
      # active screen edge. Drag windows to edge of screen to resize
      edge-tiling = true;
    };
  };
}
