#
# MacBook 12
#
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
  [ (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/hardware/network/broadcom-43xx.nix")
     ../profiles/x86_64.nix
     ../profiles/intel.nix
     ../profiles/shared.nix
     ../profiles/desktop.nix
    ];

  networking.hostName = "macbook12";

  systemd.services.fix-suspend = {
    script = ''
      # Fix macbook 12 suspend issues
      echo 0 > /sys/bus/pci/devices/0000:01:00.0/d3cold_allowed
    '';
    wantedBy = [ "multi-user.target" ];
  };

  boot.initrd.availableKernelModules = [
    "applespi"
    "intel_lpss_pci"
    "mac_hid"
    "nvme"
    "sd_mod"
    "spi_pxa2xx_platform"
    "usb_storage"
    "usbcore"
    "xhci_pci"
  ];

  boot.initrd.kernelModules = [];

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6c27deff-f5e4-4892-ab62-14efc03ac8f9";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."crypt".device = "/dev/disk/by-uuid/519d482b-c6f0-4727-ae1a-3ed347819d71";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5F66-17ED";
      fsType = "vfat";
    };


  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
