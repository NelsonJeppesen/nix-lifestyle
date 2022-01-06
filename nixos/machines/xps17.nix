# Dell XPS 17 2021 (9710)
{ config, pkgs, stdenv, lib, modulesPath, ... }:

{
  networking.hostName = "xps17";
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.luks.devices.crypt.device = "/dev/disk/by-uuid/";
  fileSystems."/".device = "/dev/disk/by-uuid/";
  fileSystems."/boot".device = "/dev/disk/by-uuid/";

  # Touchpad goes over i2c.
  # Without this we get errors in dmesg on boot and hangs when shutting down.
  #boot.blacklistedKernelModules = [ "psmouse" ];

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/desktop.nix
    ../profiles/encrypted_disk_butter.nix
    ../profiles/fingerprint.nix
    ../profiles/intel.nix
    ../profiles/systemd-boot.nix
    ../profiles/shared.nix
    ../profiles/x86_64.nix
  ];
}
