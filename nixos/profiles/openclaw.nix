# openclaw.nix - openclaw gateway service + dedicated user
#
# Sets up a systemd service running `openclaw gateway` as the openclaw
# user, opens TCP/22 and TCP/18789, and prevents the host from sleeping
# when the lid closes (this is a stationary deployment).
{
  config,
  pkgs,
  lib,
  ...
}:
{

  users.users.openclaw = {
    isNormalUser = lib.mkDefault true;
    extraGroups = lib.mkDefault [ "docker" ];
  };

  environment.systemPackages = [ pkgs.openclaw ];
  # openclaw 2026.2.26 has known CVEs that the upstream maintainer hasn't
  # patched; pin the marker so nix-build doesn't refuse the package.
  nixpkgs.config.permittedInsecurePackages = [
    "openclaw-2026.2.26"
  ];
  systemd.services.openclaw = {
    description = "OpenClaw Gateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.openclaw}/bin/openclaw gateway";
      User = "openclaw";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # prevent sleep when laptop lid is closed
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  networking.firewall = {
    allowedTCPPorts = [
      22
      18789
    ];
  };
}
