{ pkgs, ... }:
{
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  hardware.bluetooth.enable = true;
  services.pulseaudio.enable = false;
  programs.evolution.enable = false;

  boot.loader.systemd-boot.configurationLimit = 14;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.systemd-boot.enable = true;
  boot.plymouth = {
    enable = true;
    theme = "hexa_retro";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "hexa_retro" ]; })
    ];
  };

  # Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    alsa.enable = true;
    audio.enable = true;
    enable = true;
    pulse.enable = true;
  };

  # programs.steam = {
  #   enable = true;
  # };
}
