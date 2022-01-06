{ config, pkgs, stdenv, lib,... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.grub.enable = false;
}
