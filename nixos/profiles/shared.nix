{ config, pkgs, stdenv, lib, ... }:

{
  nixpkgs.config.allowUnfree  = true;     # Chrome, steam etc
  boot.consoleLogLevel        = 3;        # hide ACPI error
  documentation.enable        = false;    # I dont use local docs
  environment.defaultPackages = [];       # Remove default pacakges

  services.fwupd.enable = true;

  # Install neovim as the system's editor
  programs.neovim.enable        = true;
  programs.neovim.defaultEditor = true;
  programs.neovim.vimAlias      = true;
  programs.neovim.viAlias       = true;

  networking.useNetworkd    = true;
  networking.dhcpcd.enable  = false;
  systemd.network.enable    = true;

  # Save battery, sync to disk max 30 seconds
  #boot.kernel.sysctl = {
  #  "vm.dirty_writeback_centisecs" = 3000;
  #  "kernel.nmi_watchdog" = 1;
  #  "vm.laptop_mode" = 5;
  #};

  # trim deleted blocks from ssd
  services.fstrim.enable = true;

  # Hardlink files in nix store to save space
  nix.autoOptimiseStore = true;

  # Cleanup un-refrenced packages in the Nix store older than 30 days
  nix.gc.automatic = true;
  nix.gc.dates     = "weekly";
  nix.gc.options   = "--delete-older-than 30d";

  # Not often, but handy at times
  services.sshd.enable = true;

  users.defaultUserShell = pkgs.zsh;

  users.users.nelson.isNormalUser = true;
  users.users.nelson.extraGroups  = [ "wheel" "docker" "networkmanager"];

  programs.zsh.enable = true;

  # Core packages I use
  environment.systemPackages = with pkgs; [
    wget curl git
  ];

  # really no downside to enable this
  networking.firewall.enable = true;
}
