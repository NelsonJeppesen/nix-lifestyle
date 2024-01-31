{ config, pkgs, stdenv, lib, ... }:

{
  fileSystems."/".fsType = lib.mkDefault "xfs";
  fileSystems."/boot".fsType = lib.mkDefault "vfat";
  services.fstrim.enable = lib.mkDefault true;

  boot.initrd.luks.devices.root = {
    name = lib.mkDefault "root";
    allowDiscards = lib.mkDefault true; # slighly less secure but better for SSD lifecycle
    bypassWorkqueues = lib.mkDefault true; # https://blog.cloudflare.com/speeding-up-linux-disk-encryption/
  };
}
