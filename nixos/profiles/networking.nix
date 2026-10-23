# networking.nix - Common network setup: NetworkManager does the work (GNOME
# enables it); this adds firewall holes for KDE Connect (1714-1764) and
# Spotify Connect (57621).
{
  lib,
  ...
}:
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
}
