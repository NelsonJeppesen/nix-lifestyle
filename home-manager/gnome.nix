# gnome.nix - GNOME desktop environment configuration
#
# Configures the GNOME desktop via dconf settings including:
# - GTK file chooser behavior and Nautilus preferences
# - Interface theme (pink accent, 12h clock, no hot corners)
# - Accessibility settings (magnifier disabled)
# - Touchpad, notifications, and sound preferences
# - Custom keybindings for media controls and window management
# - Flameshot screenshot tool integration (replacing GNOME's built-in screenshot)
# - Nautilus sidebar bookmarks for quick access to project directories
{
  pkgs,
  ...
}:
let
  # Flameshot wrapper script to work around GNOME Wayland DBus issue.
  #
  # Under GNOME Wayland, launching flameshot via its DBus interface does not
  # work correctly -- the screenshot region selector fails to appear or hangs.
  # This wrapper invokes flameshot directly as a subprocess instead of relying
  # on DBus activation, which sidesteps the issue entirely.
  #
  # See: https://github.com/flameshot-org/flameshot/issues/2848
  #
  # NOTE: The flameshot package itself is patched in flake.nix to pull an
  # unreleased commit that fixes clipboard copy under GNOME Wayland.
  flameshot-gui = pkgs.writeShellScriptBin "flameshot-gui" "${pkgs.flameshot}/bin/flameshot gui";
in
{

  # Nautilus sidebar bookmarks for quick navigation
  home.file.".config/gtk-3.0/bookmarks".text = ''
    file:///home/nelson/source/personal
    file:///home/nelson/source
    file:///s3fs s3fs
  '';

  dconf.settings = {
    # GTK4 file chooser: sort directories before files
    "org/gtk/gtk4/settings/file-chooser" = {
      sort-directories-first = true;
    };

    # Disable the screen magnifier accessibility feature
    "org/gnome/desktop/a11y/applications" = {
      "screen-magnifier-enabled" = false;
    };

    # GNOME interface preferences
    "org/gnome/desktop/interface" = {
      toolkit-accessibility = false;
      accent-color = "pink"; # System-wide accent color
      clock-format = "12h";
      enable-hot-corners = false; # Disable hot corners to prevent accidental triggers
      show-battery-percentage = true;
    };

    # Magnifier defaults (effectively disabled but configured just in case)
    "org/gnome/desktop/a11y/magnifier" = {
      mag-factor = 1.0;
      brightness-red = 0.01;
      brightness-blue = 0.01;
      brightness-green = 0.01;
      contrast-red = -0.04;
      contrast-blue = -0.04;
      contrast-green = -0.04;
    };

    # Enable location services (used by Night Light, weather, etc.)
    "org/gnome/system/location" = {
      enabled = true;
    };

    # Nautilus list view: enable tree view and configure visible columns
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

    # Nautilus behavior: show "delete permanently" option, require double-click
    "org/gnome/nautilus/preferences" = {
      show-delete-permanently = true;
      click-policy = "double";
    };

    # Disable tap-to-click on touchpad (prefer physical clicks)
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = false;
    };

    # Hide notifications on the lock screen for privacy
    "org/gnome/desktop/notifications" = {
      show-in-lock-screen = false;
    };

    # Sound: allow volume above 100% for external speakers, disable UI sounds
    "org/gnome/desktop/sound" = {
      allow-volume-above-100-percent = true;
      event-sounds = false;
    };

    # Window manager keybindings
    # Free up keys that conflict with custom bindings (run-or-raise, flameshot)
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ ]; # Free up <Super>space for app launcher
      switch-input-source-backward = [ ]; # Free up <Super><Shift>space
      toggle-message-tray = [ "<Super>v" ]; # Reassign from <Super>m
      close = [ "<Super>BackSpace" ]; # Close window
      toggle-fullscreen = [ "<Super>Print" ]; # Fullscreen toggle
    };

    # Mutter (GNOME compositor) settings
    "org/gnome/mutter" = {
      overlay-key = "Super_R"; # Use right Super for Activities overlay
      edge-tiling = true; # Enable window snapping to screen edges
    };

    # Shell keybindings: free up keys for custom use
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ ]; # Free up Print key for flameshot
      toggle-application-view = [ ]; # Free up Super+A
      toggle-message-tray = [ "<Super>v" ];
      toggle-quick-settings = [ ]; # Free up Super+S
    };

    # Media key and custom keybinding configuration
    "org/gnome/settings-daemon/plugins/media-keys" = {
      # Media playback controls (Super + bracket keys)
      next = [ "<Super>bracketright" ];
      play = [ "<Super>backslash" ];
      previous = [ "<Super>bracketleft" ];

      # Super+Space opens GNOME search (acts as app launcher)
      search = [ "<Super>space" ];

      # Free up the default screenshot key so flameshot can use it
      screenshot = [ ];

      # Volume controls (Shift+Super + brace keys)
      volume-down = [ "<Shift><Super>braceleft" ];
      volume-up = [ "<Shift><Super>braceright" ];

      # Register custom keybinding slots
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    # Custom keybinding: Print key launches flameshot screenshot tool
    # Uses the wrapper script (see flameshot-gui above) instead of DBus
    # activation to work around GNOME Wayland compatibility issues
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "Print";
      command = "${flameshot-gui}/bin/flameshot-gui";
      name = "flameshot screenshot";
    };

    # Allow extensions regardless of GNOME Shell version mismatches
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      disable-user-extensions = false;
    };
  };
}
