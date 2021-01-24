#
# Raspberry Pi 4
#

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_usb_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d2899aec-29ec-4dbc-b9db-2a1d5f678dcf";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2B58-7FF6";
      fsType = "vfat";
    };

  swapDevices = [ ];

  networking.hostName = "blue";

  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
