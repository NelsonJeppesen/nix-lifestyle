# networking.nix - Common network setup: systemd-networkd, firewall holes
# for KDE Connect (1714-1764) and Spotify Connect (57621), and the
# NetworkManager VPN plugins for OpenVPN/Fortinet SSL VPN.
{ pkgs, lib, ... }:
{

  networking = {
    modemmanager.enable = false;

    dhcpcd.enable = lib.mkDefault false;

    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPortRanges = [
        {
          # Open KDE Connect
          from = 1714;
          to = 1764;
        }
      ];

      allowedUDPPortRanges = [
        {
          # Open KDE Connect
          from = 1714;
          to = 1764;
        }
        {
          # Open Spotify Connect
          from = 57621;
          to = 57621;
        }
      ];
    };
  };

  systemd.network = {
    enable = lib.mkDefault true;
    wait-online.enable = lib.mkDefault false;
  };

  networking.networkmanager.plugins = [
    pkgs.networkmanager-openvpn
    pkgs.networkmanager-fortisslvpn
  ];
}
