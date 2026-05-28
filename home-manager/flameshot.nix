# flameshot.nix - Flameshot screenshot tool
#
# Enables the user systemd service so the daemon is running and bound to
# graphical-session.target. The Print-key binding (see gnome.nix) invokes
# `flameshot gui` directly.
#
# History: flameshot v14.0.rc1 hard-coded parent_window="" when calling
# org.freedesktop.portal.Screenshot, which xdg-desktop-portal-gnome >= 46
# rejected -- so an org.flameshot.Flameshot.captureScreen D-Bus workaround
# script used to live here. Fixed upstream in flameshot 13.3.0 (current
# pinned); workaround removed 2026-05-28.
{ ... }:
{
  services.flameshot = {
    enable = true;
    settings = {
      General = {
        # Don't pop the "Welcome to Flameshot" message on every restart
        showStartupLaunchMessage = false;
        # Hide the tray icon (Print key is the only entry point)
        disabledTrayIcon = true;
      };
    };
  };
}
