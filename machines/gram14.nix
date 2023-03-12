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

  # Core packages I use
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    virtualbox
    vagrant
  ];

  #boot.initrd.systemd.enable = true;

  #virtualisation.virtualbox.guest.enable = true;
  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;

  networking.hostName = "xps17";
  system.stateVersion = "22.05";
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.luks.devices.root.device = "/dev/disk/by-uuid/c4a5062a-5060-4351-8f70-7cec63cd0487";

  fileSystems."/".device = "/dev/disk/by-uuid/87a61706-201f-469c-b399-490f83109760";
  fileSystems."/".fsType = "btrfs";
  fileSystems."/".options = [ "noatime" "nodiratime" "discard=async" "autodefrag" ];
  fileSystems."/boot".device = "/dev/disk/by-uuid/E7AF-1131";
  swapDevices = [ { device = "/dev/disk/by-uuid/c09b6f9b-c7ad-4672-91c2-895a40de81b5"; } ];

  systemd.services.enable_fn_lock= {
    script = ''
      # Enable fn-lock
      echo 1 > /sys/devices/platform/lg-laptop/fn_lock
    '';
    wantedBy = [ "multi-user.target" ];
  };

  # fix issues with bluetooth preventing sleep
#  powerManagement.powerDownCommands = "${pkgs.util-linux}/bin/rfkill block bluetooth";
#  powerManagement.powerUpCommands = "
#    /bin/sh -c 'sleep 2'
#    ${pkgs.util-linux}/bin/rfkill unblock bluetooth
#    ";
}
