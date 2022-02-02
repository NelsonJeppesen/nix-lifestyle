{ config, pkgs, stdenv, lib, ... }:

{
  boot.kernelPackages           = pkgs.linuxPackages_latest;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
    };
  };
}
