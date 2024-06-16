{
  config,
  pkgs,
  stdenv,
  lib,
  ...
}:
{
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
  }; # monday is the start of the week

  console.earlySetup = lib.mkDefault true; # Set virtual console options in initrd
  environment.defaultPackages = lib.mkDefault [ ]; # Remove default pacakges
  nixpkgs.config.allowUnfree = true; # Chrome, steam etc
  programs.zsh.enable = true;
  security.sudo.extraConfig = "Defaults timestamp_timeout=600";
  services.dbus.implementation = "broker";
  users.defaultUserShell = pkgs.zsh;

  environment.sessionVariables = rec {
    MOZ_ENABLE_WAYLAND = "1";
  };
  nix.extraOptions = "experimental-features = nix-command flakes";
  services.fwupd.enable = lib.mkDefault true;

  # Install neovim as the system's editor
  programs.neovim.enable = lib.mkDefault true;
  programs.neovim.defaultEditor = lib.mkDefault true;
  programs.neovim.vimAlias = lib.mkDefault true;
  programs.neovim.viAlias = lib.mkDefault true;

  zramSwap.enable = lib.mkDefault true;

  nix = {
    gc = {
      automatic = lib.mkDefault true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 30d";
    };
  };

  services.sshd.enable = lib.mkDefault true;
  users.users.nelson.isNormalUser = lib.mkDefault true;

  users.users.nelson.extraGroups = lib.mkDefault [
    "i2c"
    "dialout"
    "wheel"
    "docker"
    "networkmanager"
    "plugdev"
  ];

  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    btop
    screen
  ];
}
