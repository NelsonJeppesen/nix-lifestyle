{
  config,
  pkgs,
  stdenv,
  lib,
  ...
}:
let

  # dumb hack to get godaddy certs working outside of a browser
  cert = builtins.fetchurl {
    url = "https://certs.godaddy.com/repository/gd_bundle-g2-g1.crt";
    sha256 = "0n6qpxm8mzl1fx4xw3yzmq1lx910csa73ijqc8xmbqild970390a";
  };
in
{
  hardware.bluetooth.enable = true;
  services.pulseaudio.enable = false;

  #boot.initrd.systemd.enable = true;
  #boot.initrd.unl0kr.enable = true;
  boot.kernelParams = [ "quiet" ];
  boot.loader.systemd-boot.configurationLimit = 14;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.systemd-boot.enable = true;
  boot.plymouth.enable = true;
  #services.fprintd.enable = true;

  security.pki.certificates = [ cert ];

  # Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    alsa.enable = true;
    audio.enable = true;
    enable = true;
    pulse.enable = true;
  };
}
