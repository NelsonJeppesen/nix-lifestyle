{ config, pkgs, stdenv, lib, ... }:

{
  # Enable fingerprint reader for login but not sudo
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = false;
}
