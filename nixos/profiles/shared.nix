{ config, pkgs, stdenv, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.systemd-boot.enable = true;
  boot.consoleLogLevel = 3; # hide ACPI error

  services.fstrim = {
    enable = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  services.sshd.enable = true;

  users.defaultUserShell = pkgs.zsh;

  users.users.nelson = {
    isNormalUser = true;

    # sudo, docker and wifi managment
    extraGroups = [ "wheel" "docker" "networkmanager"];
  };

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    wget vim firefox zsh git powertop
  ];

  networking.firewall.enable = true;
}
