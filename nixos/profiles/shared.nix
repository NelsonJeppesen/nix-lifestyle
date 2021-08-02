{ config, pkgs, stdenv, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;
  boot.consoleLogLevel = 3; # hide ACPI error
  documentation.enable = false;
  environment.defaultPackages = [];

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimAlias = true;
  programs.neovim.viAlias = true;

  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  systemd.network.enable = true;

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
    wget curl git
  ];

  networking.firewall.enable = true;
}
