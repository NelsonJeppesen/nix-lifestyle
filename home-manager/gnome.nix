{ config, lib, pkgs, ... }:
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      enable-hot-corners = false;
      show-battery-percentage = false;
    };

    # Use capslock as super key
    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "caps:super" # map capslock to windows/mac key
        "numpad:mac" # always enable numlock
        "f:XF86AudioRaiseVolume"
      ];
    };

    "org/gnome/desktop/sound" = {
      event-sounds = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ ]; # Free up <Super>space
      switch-input-source-backward = [ ]; # Free up <Super><Shift>space
      toggle-message-tray = [ "<Super>v" ]; # Free up <Super>m
      close = [ "<Super>BackSpace" ];
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_R";
      edge-tiling = true;
    };

    "org/gnome/shell/keybindings" = {
      toggle-message-tray = [ "<Super>v" ];
      toggle-overview = [ ]; # free super-s
    };

    # map the mappings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      next = [ "<Super>bracketright" ];
      play = [ "<Super>backslash" ];
      previous = [ "<Super>bracketleft" ];
      search = [ "<Super>space" ];
      screenshot = [ ]; # free up for flameshot
      volume-down = [ "<Shift><Super>braceleft" ];
      volume-up = [ "<Shift><Super>braceright" ];

      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "Print";
      command = "${pkgs.flameshot}/bin/flameshot gui";
      name = "flameshot screenshot";
    };

    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      disable-user-extensions = false;
    };

  };
}
