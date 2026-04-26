# gnome.nix - GNOME desktop environment configuration
#
# Configures the GNOME desktop via dconf settings including:
# - GTK file chooser behavior and Nautilus preferences
# - Interface theme (pink accent, 12h clock, no hot corners)
# - Accessibility settings (magnifier disabled)
# - Touchpad, notifications, and sound preferences
# - Custom keybindings for media controls and window management
# - Flameshot Print-key binding (the daemon + capture-trigger live in flameshot.nix)
# - Nautilus sidebar bookmarks for quick access to project directories
{
  config,
  ...
}:
{

  # Nautilus sidebar bookmarks for quick navigation
  home.file.".config/gtk-3.0/bookmarks".text = ''
    file://${config.home.homeDirectory}/source/personal
    file://${config.home.homeDirectory}/source
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
      toolkit-accessibility = false; # Disable ATK/AT-SPI bridge (no screen readers in use)
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

    # Free Super+P (default switch-monitor) so it can be grabbed by other apps
    "org/gnome/mutter/keybindings" = {
      switch-monitor = [ "XF86Display" ];
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

    # Custom keybinding: Print key launches flameshot screenshot tool.
    # Invokes the flameshot-capture script (installed by flameshot.nix)
    # rather than `flameshot gui` directly -- the CLI path is broken on
    # GNOME Wayland (xdg-desktop-portal-gnome rejects the empty parent_window
    # flameshot v14.0.rc1 sends). The script calls
    # org.flameshot.Flameshot.captureScreen on the session bus, which runs
    # the capture from inside the daemon (real window context the portal
    # accepts) -- same code path the tray's "Take Screenshot" entry uses,
    # but without depending on the tray icon being enabled. See flameshot.nix
    # for the full story.
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "Print";
      command = "${config.home.homeDirectory}/.local/bin/flameshot-capture";
      name = "flameshot screenshot";
    };

    # Allow extensions regardless of GNOME Shell version mismatches
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      disable-user-extensions = false;
    };
  };
}
