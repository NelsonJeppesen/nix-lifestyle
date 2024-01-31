# LG Gram 17 17Z90Q Intel 12th Gen
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }:
{
  imports = [
    #(modulesPath + "/installer/scan/not-detected.nix")
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ../profiles/software_defined_radio.nix
    ../profiles/desktop.nix
    ../profiles/intel.nix
    ../profiles/shared.nix
    ../profiles/systemd-boot.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  boot.kernelParams = [ "acpi_mask_gpe=0x6E" ];
  system.stateVersion = "23.05";

  # Fix ACPI errors
  #
  #   ACPI Error: No handler for Region [XIN1] (000000005158740d) [UserDefinedRegion] (20221020/evregion-130)
  #   ACPI Error: Region UserDefinedRegion (ID=143) has no handler (20221020/exfldio-261)
  #   ACPI Error: Aborting method \_SB.PC00.LPCB.LGEC.SEN2._TMP due to previous error (AE_NOT_EXIST) (20221020/psparse-529)
  boot.blacklistedKernelModules = [ "int3403_thermal" ];

  systemd.services.enable_fn_lock = {
    script = ''
      # Enable fn-lock
      echo 1 > /sys/devices/platform/lg-laptop/fn_lock
    '';
    wantedBy = [ "multi-user.target" ];
  };
}
