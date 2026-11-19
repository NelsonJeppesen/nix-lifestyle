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
      # `vdb` contributes to generated partition labels. Keep this key stable
      # unless migrating labels; each machine supplies its installation device.
      vdb = {
        type = "disk";
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
                  # Low-level zstd compression trades CPU for fewer stored bytes;
                  # the saving depends on content. noatime avoids access-time
                  # writes, and omitting autodefrag avoids extra rewrite work.
                  # Existing data stays uncompressed until rewritten.
                  mountOptions = [
                    "compress=zstd:1"
                    "noatime"
                    "discard=async"
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
