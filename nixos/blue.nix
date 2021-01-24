#
# Raspberry Pi 4
#
{ config, pkgs, ... }:

{

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  networking.hostName = "blue";
  networking.networkmanager.enable = true;

  # Enable the OpenSSH server.
  services.sshd.enable = true;

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  services.fstrim.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  nixpkgs.config.allowUnfree = true;

  users.defaultUserShell = pkgs.zsh;

  users.users.nelson = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    wget neovim zsh
  ];

  system.stateVersion = "20.09"; # Did you read the comment?

}
