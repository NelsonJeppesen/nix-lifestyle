# LG Gram 17" 20201 (17Z90P K.AAB8U1)
{ config, pkgs, stdenv, lib, modulesPath, ... }:

{

imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/x86_64.nix
    ../profiles/intel.nix
    ../profiles/shared.nix
    ../profiles/desktop.nix
    ../profiles/encrypted_disk.nix
    ../profiles/systemd-boot.nix
  ];

  networking.hostName = "gram";

  networking.firewall.enable = false;

  boot.kernelModules  = [ "kvm-intel" ];
  boot.kernelParams   = [ "mem_sleep_default=deep" ];

  boot.initrd.luks.devices.crypt.device = "/dev/disk/by-uuid/e5587b91-ce02-45b1-b570-d925b9345fc7";
  fileSystems."/".device = "/dev/disk/by-uuid/43c7d480-0c9d-4cd6-9dad-086b67b79440";
  fileSystems."/boot".device = "/dev/disk/by-uuid/FA89-9F6E";

  systemd.services.fix-suspend = {
    script = ''
      # Enable fn-lock
      echo 1 > /sys/devices/platform/lg-laptop/fn_lock
    '';
    wantedBy = [ "multi-user.target" ];
  };
}
