{ config, pkgs, stdenv, lib,... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  #boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
}
