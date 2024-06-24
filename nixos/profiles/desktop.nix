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

  security.pki.certificates = [ cert ];

  # Pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    alsa.enable = true;
    enable = true;
    pulse.enable = true;
  };
}
