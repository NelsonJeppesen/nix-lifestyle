{ config, pkgs, stdenv, lib, ... }:

{
  boot.kernelPackages =  pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  virtualisation.docker.enable = true;
}
