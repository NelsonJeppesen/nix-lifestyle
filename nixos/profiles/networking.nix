{ config, pkgs, stdenv, lib, ... }: {
  networking = {
    dhcpcd.enable = lib.mkDefault false;

    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPortRanges = [{
        # Open KDE Connect
        from = 1714;
        to = 1764;
      }];

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
}
