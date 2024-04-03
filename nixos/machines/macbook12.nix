# Apple MacBook 12
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }: {
  system.stateVersion = "23.11";

  imports = [
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/shared.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  # make this a "server"
  services.logind.lidSwitch = "ignore"

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
}
