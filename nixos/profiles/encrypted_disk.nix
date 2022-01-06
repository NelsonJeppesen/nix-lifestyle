{ config, pkgs, stdenv, lib,... }:

{
  fileSystems."/boot".fsType  = lib.mkDefault "vfat";
  fileSystems."/".fsType      = lib.mkDefault "xfs";

  boot.initrd.luks.devices.crypt = {
    allowDiscards     = lib.mkDefault true;  # slighly less secure but better for SSD lifecycle
    bypassWorkqueues  = lib.mkDefault true;  # https://blog.cloudflare.com/speeding-up-linux-disk-encryption/
  };
}
