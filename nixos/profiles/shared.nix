{ config, pkgs, stdenv, lib, ... }:

{
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  nixpkgs.config.allowUnfree = true;
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = true;
  sound.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  services.fstrim = {
    enable = true;
  };

  services.sshd.enable = true;

  services.tlp = lib.mkIf (
    config.networking.hostName == "black" ||
    config.networking.hostName == "white"
  ) {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC    = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT   = "powersave";
      DEVICES_TO_DISABLE_ON_STARTUP ="bluetooth";
      SATA_LINKPWR_ON_AC            ="min_power";
      SATA_LINKPWR_ON_BAT           ="min_power";
      CPU_BOOST_ON_AC               ="1";
      CPU_BOOST_ON_BAT              ="0";
    };
  };

  # Enable the GNOME 3 Desktop Environment.
  services.xserver = {
    desktopManager.gnome3.enable = true;
    displayManager.gdm.enable = true;
    videoDrivers = ["amdgpu"];
    enable = true;

    libinput = {
      enable = true;
      accelProfile = "flat";
    };
  };

  environment.gnome3.excludePackages = with pkgs; [
    gnome3.gnome-music
    gnome3.cheese
    gnome3.gnome-contacts
    gnome3.geary
  ];

  # Configure keymap in X11
  services.xserver.layout = "us";

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
    wget vim firefox zsh git
  ];

  # networking.firewall.enable = false;
  system.stateVersion = "20.09"; # Did you read the comment?
}
