{ config, pkgs, stdenv, lib, ... }:
{
  networking = {
    dhcpcd.enable = lib.mkDefault false;

    firewall = {
      enable = lib.mkDefault true;

      # Open KDE Connect
      allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
      allowedUDPPortRanges = [{ from = 1714; to = 1764; }];
    };
  };

  systemd.network = {
    enable = lib.mkDefault true;
    wait-online.enable = lib.mkDefault false;
  };
}
