{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  nixpkgs.config.allowUnfree = true; 
  #hardware.bluetooth.enable = false;
  #hardware.opengl.extraPackages = [ pkgs.amdvlk ];
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = true;
  sound.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  services.fstrim = {
    enable = true;
  };

  services.tlp = { 
    enable = true; 
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      DEVICES_TO_DISABLE_ON_STARTUP="bluetooth";
      SATA_LINKPWR_ON_AC="min_power";
      SATA_LINKPWR_ON_BAT="min_power";
      CPU_BOOST_ON_AC="1";
      CPU_BOOST_ON_BAT="0";
    };
  };

  systemd.services.disable-dgpu = {
    script = ''
      # Disable nvidia dgpu by default g14
      echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control
    '';
    wantedBy = [ "multi-user.target" ];
  };

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

  users.defaultUserShell = pkgs.zsh;

  users.users.nelson = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  users.users.alex = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  #fonts.fonts = with pkgs; [
  #  nerdfonts
  #];

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    wget vim firefox zsh
  ];

  # networking.firewall.enable = false;
  system.stateVersion = "20.09"; # Did you read the comment?

}
