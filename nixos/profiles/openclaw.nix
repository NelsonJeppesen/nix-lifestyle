{
  config,
  pkgs,
  stdenv,
  lib,
  ...
}:
{

  users.users.openclaw.isNormalUser = lib.mkDefault true;
  users.users.openclaw.extraGroups = lib.mkDefault [
    "docker"
  ];

  networking.firewall = {
    allowedTCPPorts = [ 22 ];
  };
}
