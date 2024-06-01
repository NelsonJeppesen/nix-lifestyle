# Apple MacBook 12
#
# The most cute server in the world
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }: {
  system.stateVersion = "23.11";

  imports = [
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/shared.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
  ];

  services.k3s.enable = true;
  services.k3s.role = "server";

  services.atuin.enable = true;
  services.atuin.host = "0.0.0.0";
  services.atuin.openRegistration = true;
  services.atuin.openFirewall = true;


  #fbset -fb /dev/fb0 -g 2560 1600 2560 1600 32
  #setterm --resize

  #services.tlp.enable = true;
  #powerManagement.enable = true;

  systemd.services.console-fbset = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStartPost="${pkgs.util-linux}/bin/setterm -resize";
      ExecStartPre="/run/current-system/sw/bin/sleep 15";
      ExecStart="${pkgs.fbset}/bin/fbset -fb /dev/fb0 -g 2304 1440 2304 1440 32";
      TTYPath="/dev/console";
      StandardOutput="tty";
      StandardInput="tty-force";
    };
    wantedBy = ["multi-user.target"];
    environment = {
      TERM = "linux";
    };
  };

  systemd.services.console-blank = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/setterm -blank 1 -powerdown 1";
      TTYPath="/dev/console";
      StandardOutput="tty";
    };
    wantedBy = ["multi-user.target"];
    environment = {
      TERM = "linux";
    };
  };

  environment.systemPackages = [ pkgs.k3s ];

  # make this a "server"
  services.logind.lidSwitch = "ignore";
  networking.networkmanager.enable = true;

  boot.initrd.availableKernelModules = [
    "applespi"
    "intel_lpss_pci"
    "mac_hid"
    "nvme"
    "sd_mod"
    "spi_pxa2xx_platform"
    "usb_storage"
    "usbcore"
    "xhci_pci"
  ];
}
