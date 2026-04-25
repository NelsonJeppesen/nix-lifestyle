# x86_64.nix - x86_64 hardware baseline: latest kernel, systemd-boot,
# podman (docker-compat), and the disko-managed disk layout (LUKS+TPM2,
# btrfs root, EFI system partition).
#
# `disko` is provided as a flake input via specialArgs (see ../flake.nix).
{
  pkgs,
  lib,
  disko,
  ...
}:

{
  imports = [ disko.nixosModules.disko ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.systemd.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
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
      # Attribute name is leftover from VM days; the actual device is
      # /dev/nvme0n1 below. Renaming the attr would change partition
      # labels and risk a remount, so it's left alone.
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
                format = "vfat";
                mountOptions = [ "defaults" ];
                mountpoint = "/boot";
                type = "filesystem";
              };
            };

            luks = {
              size = "100%";
              content = {
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [ "tpm2-device=auto" ];
                };
                name = "crypted";
                type = "luks";

                content = {
                  extraArgs = [ "-f" ];
                  mountOptions = [
                    "discard=async"
                    "autodefrag"
                  ];
                  mountpoint = "/";
                  format = "btrfs";

                  type = "filesystem";
                };
              };
            };

          };
        };
      };
    };
  };
}
