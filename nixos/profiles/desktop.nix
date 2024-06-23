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
    sha256 = "0aa4014e6a34e2553b6258c671946620a44e03aedf0fde497781fe8a6abfd858";
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
