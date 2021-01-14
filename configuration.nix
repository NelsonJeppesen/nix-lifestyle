{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true; 

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.blacklistedKernelModules = [ "nouveau" ];

  services.tlp = {
    enable = true;
  };

  boot = {
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  hardware.opengl.extraPackages = [ pkgs.amdvlk ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Enable the GNOME 3 Desktop Environment.
  services.xserver = { 
    desktopManager.gnome3.enable = true;
    displayManager.gdm.enable = true;
    enable = true;
    videoDrivers = ["amdgpu"];
    
    libinput = {
      enable = true;
      accelProfile = "flat";
    };

  };
   
  # Configure keymap in X11
  services.xserver.layout = "us";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.opengl.driSupport = true;

users.defaultUserShell = pkgs.zsh;

  users.users.nelson = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    #shell = pkgs.zsh;
  };

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    #shell = pkgs.zsh;
  };

  #fonts.fonts = with pkgs; [
  #  nerdfonts
  #];

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    wget vim kitty firefox zsh
  ];

  # networking.firewall.enable = false;
  system.stateVersion = "20.09"; # Did you read the comment?

}

