# flameshot.nix - Flameshot screenshot tool
#
# Enables the user systemd service so the daemon is running and bound to
# graphical-session.target. The Print-key binding (see gnome.nix) invokes
# `flameshot gui` directly.
#
# Package source: upstream flameshot flake pinned to master commit 410cfae
# (PR #4664) — the fix for the empty parent_window xdg-desktop-portal bug
# that breaks `flameshot gui` on GNOME Wayland. nixpkgs still ships v13.3.0,
# which lacks the fix. See flake.nix for the pin. Drop the `flameshot` input
# and revert `package` to `pkgs.flameshot` once nixpkgs ships a release
# containing 410cfae.
{
  pkgs,
  flameshot,
  ...
}:
{
  services.flameshot = {
    enable = true;
    package = flameshot.packages.${pkgs.system}.flameshot;
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
