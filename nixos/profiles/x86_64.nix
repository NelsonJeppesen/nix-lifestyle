{ config, pkgs, stdenv, lib, ... }:

{
  imports = [
    "${
      builtins.fetchTarball
      "https://github.com/nix-community/disko/archive/master.tar.gz"
    }/module.nix"
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        consoleMode = "auto";
        enable = true;
      };
    };
  };

  hardware.enableAllFirmware = true;
  services.fstrim.enable = lib.mkDefault true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  disko.devices = {
    disk = {
      vdb = {
        type = "disk";
        device = lib.mkDefault "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {

            ESP = {
              label = "ESP";
              name = "ESP";
              size = "2G";
              type = "EF00";

              content = {
                format = "vfat";
                mountOptions = [ "defaults" ];
                mountpoint = "/boot";
                type = "filesystem";
              };
            };

            luks = {
              size = "100%";
              content = {
                extraOpenArgs = [ "--allow-discards" ];
                name = "crypted";
                type = "luks";

                content = {
                  extraArgs = [ "-f" ];
                  mountOptions = [ "discard=async" "autodefrag" ];
                  mountpoint = "/";
                  type = "btrfs";
                };
              };
            };

          };
        };
      };
    };
  };
}
