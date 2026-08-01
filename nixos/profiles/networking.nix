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

  # HaProxy 3.0 CA Prod - hosts file test entries
  networking.extraHosts = ''
    # nslookup prodca-haproxy30-webs-pd-16168ebdf291eab3.elb.ca-central-1.amazonaws.com
    16.52.53.237     privatedomain.alchemer-ca.com

    # nslookup prodca-haproxy30-apps-public-1284526185.ca-central-1.elb.amazonaws.com
    52.60.223.159    app.alchemer-ca.com reporting.alchemer-ca.com api.alchemer-ca.com

    # nslookup prodca-haproxy30-webs-public-2056957719.ca-central-1.elb.amazonaws.com
    16.52.65.105    survey.alchemer-ca.com
    16.52.65.105    s.alchemer-ca.com
  '';
}
