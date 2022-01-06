{ config, pkgs, stdenv, lib,... }:

{
  fileSystems."/boot".fsType  = "vfat";
  fileSystems."/".fsType      = "btrfs";

  # slighly less secure but better for SSD lifecycle
  boot.initrd.luks.devices.crypt.allowDiscards = true;

  # https://blog.cloudflare.com/speeding-up-linux-disk-encryption/
  boot.initrd.luks.devices.crypt.bypassWorkqueues = true;
}
