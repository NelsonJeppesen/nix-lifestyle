{ config, pkgs, stdenv, lib, ... }:

{
  fileSystems."/boot".fsType = lib.mkDefault "vfat";
  fileSystems."/".fsType = lib.mkDefault "xfs";

  boot.initrd.luks.devices.root = {
    name = lib.mkDefault "root";
    allowDiscards = lib.mkDefault true; # slighly less secure but better for SSD lifecycle
    bypassWorkqueues = lib.mkDefault true; # https://blog.cloudflare.com/speeding-up-linux-disk-encryption/
  };
}
