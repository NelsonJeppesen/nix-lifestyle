{
  pkgs,
  ...
}:
let
  # https://github.com/flameshot-org/flameshot/issues/2848
  flameshot-gui = pkgs.writeShellScriptBin "flameshot-gui" "${pkgs.flameshot}/bin/flameshot gui --raw | wl-copy";
in
{

  home.file.".config/gtk-3.0/bookmarks".text = ''
    file:///home/nelson/source/personal
    file:///home/nelson/source
    file:///s3fs s3fs
  '';

  dconf.settings = {
    "org/gtk/gtk4/settings/file-chooser" = {
      sort-directories-first = true;
    };

    "org/gnome/desktop/a11y/applications" = {
      "screen-magnifier-enabled" = false;
    };

    "org/gnome/desktop/interface" = {
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/a11y/magnifier" = {
      mag-factor = 1.0;
      brightness-red = 0.01;
      brightness-blue = 0.01;
      brightness-green = 0.01;
      contrast-red = -0.04;
      contrast-blue = -0.04;
      contrast-green = -0.04;
    };

    "org/gnome/system/location" = {
      enabled = true;
    };

    "org/gnome/nautilus/list-view" = {
      use-tree-view = true;

      default-visible-columns = [
        "name"
        "size"
        "type"
        "date_modified"
      ];

      default-column-order = [
        "name"
        "size"
        "type"
        "owner"
        "group"
        "permissions"
        "date_modified"
        "date_accessed"
        "date_created"
        "recency"
        "detailed_type"
      ];
    };

    "org/gnome/nautilus/preferences" = {
      show-delete-permanently = true;
      click-policy = "double";
    };

    "org/gnome/desktop/interface" = {
      accent-color = "pink";
      clock-format = "12h";
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = false;
    };

    # Use capslock as super key
    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "caps:super" # map capslock to windows/mac key
        "numpad:mac" # always enable numlock
        "f:XF86AudioRaiseVolume"
      ];
    };

    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
    };

    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
      event-sounds = false;
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ ]; # Free up <Super>space
      switch-input-source-backward = [ ]; # Free up <Super><Shift>space
      toggle-message-tray = [ "<Super>v" ]; # Free up <Super>m
      close = [ "<Super>BackSpace" ];
      toggle-fullscreen = [ "<Super>Print" ];
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_R";
      edge-tiling = true;
    };

    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ ]; # free up Print
      toggle-application-view = [ ]; # free up super-a
      toggle-message-tray = [ "<Super>v" ];
      toggle-quick-settings = [ ]; # free up super-s
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
      command = "${flameshot-gui}/bin/flameshot-gui";
      name = "flameshot screenshot";
    };

    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      disable-user-extensions = false;
    };
  };
}
