{ config, pkgs, stdenv, lib, ... }:
let
  base = "https://raw.githubusercontent.com/NelsonJeppesen/nix-lifestyle/main";
  zsh = builtins.fetchurl "${base}/nixos/profiles/zsh.nix";
in
{
  imports = [zsh];
  nixpkgs.config.allowUnfree  = true;     # Chrome, steam etc
  #boot.consoleLogLevel        = lib.mkDefault 3;        # hide ACPI error
  console.earlySetup          = lib.mkDefault true;     # Set virtual console options in initrd
  #documentation.enable        = lib.mkDefault false;    # I dont use local docs
  environment.defaultPackages = lib.mkDefault [];       # Remove default pacakges
  hardware.video.hidpi.enable = lib.mkDefault true;

  environment.sessionVariables = rec {
    MOZ_ENABLE_WAYLAND= "1";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  services.fwupd.enable = lib.mkDefault true;

  # Install neovim as the system's editor
  programs.neovim.enable        = lib.mkDefault true;
  programs.neovim.defaultEditor = lib.mkDefault true;
  programs.neovim.vimAlias      = lib.mkDefault true;
  programs.neovim.viAlias       = lib.mkDefault true;

  networking.useNetworkd        = lib.mkDefault true;
  networking.dhcpcd.enable      = lib.mkDefault false;
  systemd.network.enable        = lib.mkDefault true;

  # trim deleted blocks from ssd
  services.fstrim.enable        = lib.mkDefault true;

  nix = {
    gc = {
      # Cleanup un-refrenced packages in the Nix store older than 30 days
      automatic = lib.mkDefault true;
      dates     = lib.mkDefault "weekly";
      options   = lib.mkDefault "--delete-older-than 30d";
    };
  };

  services.sshd.enable    = lib.mkDefault true;

  users.users.nelson.isNormalUser = lib.mkDefault true;
  users.users.nelson.extraGroups  = lib.mkDefault [ "wheel" "networkmanager" "docker"];

  # Core packages I use
  environment.systemPackages = with pkgs; [
    wget curl git comma btop
  ];

  networking.firewall.enable = lib.mkDefault true;
}
