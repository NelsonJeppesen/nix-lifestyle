# Dell XPS 17 2021 (9710) without nvidia
{ config, pkgs, stdenv, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/desktop.nix
    ../profiles/encrypted_disk.nix
    ../profiles/intel.nix
    ../profiles/shared.nix
    ../profiles/software_defined_radio.nix
    ../profiles/systemd-boot.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  networking.hostName         = "xps17";
  system.stateVersion         = "21.11";
  boot.kernelModules          = ["kvm-intel"];
  boot.initrd.luks.devices.root.device  = "/dev/disk/by-uuid/a8e22006-dab1-467e-b3d9-05474903aa2d";

  fileSystems."/".device      = "/dev/disk/by-uuid/4d559904-9470-4926-a90c-bbaf08e45e4c";
  fileSystems."/".fsType      = "btrfs";
  fileSystems."/".options     = ["noatime" "nodiratime" "discard=async" "autodefrag"];
  fileSystems."/boot".device  = "/dev/disk/by-uuid/8E00-9764";

  # fix issues with bluetooth preventing sleep
  powerManagement.powerDownCommands = "${pkgs.util-linux}/bin/rfkill block bluetooth";
  powerManagement.powerUpCommands   = "
    /bin/sh -c 'sleep 2'
    ${pkgs.util-linux}/bin/rfkill unblock bluetooth
    ";
}
