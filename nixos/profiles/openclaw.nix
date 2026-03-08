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

  networking.firewall = {
    allowedTCPPorts = [
      22
      18789
    ];
  };
}
