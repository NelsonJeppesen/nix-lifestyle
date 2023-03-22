#
# One Netbook One Mix 4 / OneNetbook 4
#   10" laptop with 11th gen Intel
#   https://www.1netbook.com/product/onemix-4/
#
{ config, pkgs, stdenv, lib, modulesPath, ... }:

{
  # Enable fingerprint reader for login but not sudo
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = false;

  networking.hostName = "mix4";

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/desktop.nix
    ../profiles/encrypted_disk.nix
    ../profiles/intel.nix
    ../profiles/shared.nix
    ../profiles/x86_64.nix
  ];

  boot.loader.systemd-boot.enable = true;

  boot.initrd.luks.devices."crypt".device = "/dev/disk/by-uuid/TODO";
  fileSystems."/".device =                  "/dev/disk/by-uuid/TODO";
  fileSystems."/boot".device =              "/dev/disk/by-uuid/TODO";

  hardware.video.hidpi.enable = lib.mkDefault true;
}
