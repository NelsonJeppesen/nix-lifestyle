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
