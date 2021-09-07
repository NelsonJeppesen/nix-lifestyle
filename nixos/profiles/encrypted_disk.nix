{ config, pkgs, stdenv, lib,... }:

{

  fileSystems."/boot".fsType  = "vfat";                     # standard EFI filesystem
  fileSystems."/".fsType      = "xfs";                      # safe, fast, good

  boot.initrd.luks.devices.crypt.allowDiscards = true;      # slighly less secure but better for SSD lifecycle
  boot.initrd.luks.devices.crypt.bypassWorkqueues = true;   # https://blog.cloudflare.com/speeding-up-linux-disk-encryption/
}
