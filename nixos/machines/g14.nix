#
# ASUS ROG Zephyrus G14 GA401
#
{ config, pkgs, stdenv, lib, modulesPath, ... }:

#let
#  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
#    export __NV_PRIME_RENDER_OFFLOAD=1
#    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
#    export __GLX_VENDOR_LIBRARY_NAME=nvidia
#    export __VK_LAYER_NV_optimus=NVIDIA_only
#    exec -a "$0" "$@"
#  '';
#in
{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/shared.nix
    ../profiles/x86_64.nix
    ../profiles/amd_xen.nix
    ../profiles/desktop.nix
  ];

  #environment.systemPackages = [ nvidia-offload ];
  networking.hostName = "g14";
  boot.loader.systemd-boot.enable = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "sd_mod" "cryptd" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6fd183fb-3607-4e1c-8a2a-3cc6616511f7";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."crypt".device = "/dev/disk/by-uuid/9a3075ca-f347-47db-8cd3-da72c6441005";
  boot.initrd.luks.devices."crypt".allowDiscards = true;

  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.prime = {
  #  offload.enable = true;

  #  # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
  #  intelBusId = "PCI:4:0:0";

  #  # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
  #  nvidiaBusId = "PCI:1:0:0";
  #};

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
