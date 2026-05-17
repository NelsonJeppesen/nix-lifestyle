# tailscale-systray.nix - Tailscale's official Linux system tray app
#
# Replaces the third-party `gnomeExtensions.tailscale-status` Shell
# extension. The `tailscale systray` command is bundled with the
# tailscale package itself (1.88+) and renders via the
# StatusNotifierItem D-Bus spec. On GNOME this is surfaced by the
# AppIndicator extension (already enabled in gnome-extensions.nix).
#
# Reference: https://tailscale.com/docs/features/client/linux-systray
#
# Auto-start is implemented as a systemd --user service rather than
# `tailscale configure systray --enable-startup=systemd`, so the unit
# is declared in Nix (idempotent, garbage-collected with the
# generation) instead of imperatively dropped into ~/.config/systemd.
# The unit binds to graphical-session.target so it only runs inside a
# real desktop session and stops cleanly on logout.
{ pkgs, ... }:
{
  systemd.user.services.tailscale-systray = {
    Unit = {
      Description = "Tailscale system tray";
      Documentation = [ "https://tailscale.com/docs/features/client/linux-systray" ];
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.tailscale}/bin/tailscale systray";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
