# LG Gram 14 14Z90Q-K.ARW5U1  Intel 12th Gen
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    #../profiles/software_defined_radio.nix
    ../falcon/falcon.nix
    ../profiles/desktop.nix
    ../profiles/encrypted_disk.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_12th_gen.nix
    ../profiles/networking.nix
    ../profiles/shared.nix
    ../profiles/systemd-boot.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  nixpkgs.overlays = [
    (
      self: super: { falcon-sensor = super.callPackage ../overlays/falcon-sensor.nix { }; }
    )
  ];

  system.stateVersion = "22.11";

  # laptop has 8gb of ram and it can get tight sometimes
  zramSwap.memoryPercent = 100;

  boot.initrd.luks.devices.root.device = "/dev/disk/by-uuid/c4a5062a-5060-4351-8f70-7cec63cd0487";
  fileSystems."/".device = "/dev/disk/by-uuid/87a61706-201f-469c-b399-490f83109760";
  fileSystems."/".fsType = "btrfs";
  fileSystems."/".options = [ "noatime" "nodiratime" "discard=async" "autodefrag" ];
  fileSystems."/boot".device = "/dev/disk/by-uuid/E7AF-1131";
}
