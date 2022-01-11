# Dell XPS 17 2021 (9710) without nvidia
{ config, pkgs, stdenv, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/desktop.nix
    ../profiles/encrypted_disk.nix
    ../profiles/fingerprint.nix
    ../profiles/intel.nix
    ../profiles/systemd-boot.nix
    ../profiles/shared.nix
    ../profiles/x86_64.nix
  ];

  networking.hostName         = "xps17";
  system.stateVersion         = "21.11";
  boot.kernelModules          = [ "kvm-intel" ];
  boot.initrd.luks.devices.root.device  = "/dev/disk/by-uuid/a8e22006-dab1-467e-b3d9-05474903aa2d";
  fileSystems."/".device      = "/dev/disk/by-uuid/4d559904-9470-4926-a90c-bbaf08e45e4c";
  fileSystems."/".fsType      = "btrfs";
  fileSystems."/".options     = [ "noatime" "nodiratime" ];
  fileSystems."/boot".device  = "/dev/disk/by-uuid/8E00-9764";
}
