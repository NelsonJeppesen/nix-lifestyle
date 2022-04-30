#
# Asus Mini PC PN50
#
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/shared.nix
    ../profiles/x86_64.nix
    ../profiles/amd_xen.nix
    ../profiles/desktop.nix
  ];

  networking.hostName = "pn50";
  boot.loader.systemd-boot.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
  boot.kernelModules = [ "kvm-amd" "amdgpu" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f4ba7912-ffce-4c55-be68-aa4c1a6afa14";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."crypt".device = "/dev/disk/by-uuid/e346e32d-f14b-473a-8834-6b26f5dd5f17";
  boot.initrd.luks.devices."crypt".allowDiscards = true;

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2B58-7FF6";
      fsType = "vfat";
    };

  hardware.video.hidpi.enable = lib.mkDefault true;
}
