#
# ASUS ROG Zephyrus G14 GA401
#
{ config, pkgs, stdenv, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/shared.nix
    ../profiles/x86_64.nix
    ../profiles/amd_xen.nix
    ../profiles/desktop.nix
  ];

  networking.hostName = "g14";
  boot.loader.systemd-boot.enable = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "sd_mod" "cryptd" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6fd183fb-3607-4e1c-8a2a-3cc6616511f7";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."crypt".device = "/dev/disk/by-uuid/9a3075ca-f347-47db-8cd3-da72c6441005";
  boot.initrd.luks.devices."crypt".allowDiscards = true;

  systemd.services.disable-dgpu = {
    script = ''
      # Disable nvidia dgpu by default g14
      echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control
    '';
    wantedBy = [ "multi-user.target" ];
  };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B458-5AF5";
      fsType = "vfat";
    };
}
