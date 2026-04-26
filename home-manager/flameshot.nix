# flameshot.nix - Flameshot screenshot tool (GNOME Wayland workaround)
#
# Why this module exists:
#   Flameshot v14.0.rc1 (current nixpkgs) hard-codes parent_window="" when
#   calling org.freedesktop.portal.Screenshot. xdg-desktop-portal-gnome on
#   GNOME >= 46 rejects empty parent_window with
#     "Failed to associate portal window with parent window ''"
#   so the CLI path (`flameshot gui`) fails with "Unable to capture screen".
#   Tray-triggered capture still works because the daemon has a real window
#   context the portal accepts.
#
#   Upstream refs:
#     - https://github.com/flameshot-org/flameshot/issues/4663 (root cause)
#     - https://github.com/flameshot-org/flameshot/issues/4600 (workaround)
#     - https://github.com/flameshot-org/flameshot/pull/4664   (open fix)
#
# What this module does:
#   1. Enables services.flameshot so a user systemd service runs the daemon
#      tied to graphical-session.target -- guarantees the D-Bus name is up.
#   2. Symlinks the flameshot-capture script into ~/.local/bin so the
#      Print key (configured in gnome.nix) can invoke it. The script calls
#      org.flameshot.Flameshot.captureScreen on the session bus, which runs
#      Flameshot::gui() inside the daemon (the same code path the tray's
#      "Take Screenshot" entry uses) -- and works on Wayland because the
#      daemon has a real window context the portal accepts.
#
# When PR #4664 lands and reaches nixpkgs, this whole module + the script
# can be deleted and the gnome.nix keybinding can go back to invoking
# `flameshot gui` directly.
{ pkgs, ... }:
{
  services.flameshot = {
    enable = true;
    settings = {
      General = {
        # Don't pop the "Welcome to Flameshot" message on every restart
        showStartupLaunchMessage = false;
        # Auto-copy captured region to the clipboard
        # copyAndCloseAfterUpload = true;
        # Disable the in-app update check (Nix manages updates)
        disabledTrayIcon = true;
      };
    };
  };

  # Capture-trigger script invoked by the Print keybinding (see gnome.nix).
  # Lives in dotfiles/ so it can be edited as a regular shell script.
  home.file.".local/bin/flameshot-capture" = {
    source = ./dotfiles/flameshot-capture;
    executable = true;
  };
}
