{ config, pkgs, stdenv, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.fstrim.enable = lib.mkDefault true;
  hardware.enableAllFirmware = true;

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "ESP";
              name = "ESP";
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [ "--allow-discards" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  mountpoint = "/";
                  mountOptions = [ "discard=async" "autodefrag" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
