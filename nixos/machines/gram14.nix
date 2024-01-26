# LG Gram 14 14Z90Q-K.ARW5U1  Intel 12th Gen
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    #../profiles/software_defined_radio.nix
    ../falcon/falcon.nix
    ../profiles/desktop.nix
    ../profiles/encrypted_disk.nix
    ../profiles/intel.nix
    ../profiles/shared.nix
    ../profiles/systemd-boot.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  boot.kernel.sysctl = { "vm.swappiness" = 10;};

  nixpkgs.overlays = [
    (
      self: super: {
        falcon-sensor = super.callPackage ../overlays/falcon-sensor.nix { };
      }
    )
  ];
  boot.kernelParams = [ "acpi_mask_gpe=0x6E" ];

  #programs.hyprland.enable = true;
  system.stateVersion = "22.11";
  #boot.kernelModules = [ "kvm-intel" ];
  services.fprintd.enable = true;
  # Fix ACPI errors
  #
  #   ACPI Error: No handler for Region [XIN1] (000000005158740d) [UserDefinedRegion] (20221020/evregion-130)
  #   ACPI Error: Region UserDefinedRegion (ID=143) has no handler (20221020/exfldio-261)
  #   ACPI Error: Aborting method \_SB.PC00.LPCB.LGEC.SEN2._TMP due to previous error (AE_NOT_EXIST) (20221020/psparse-529)
  boot.blacklistedKernelModules = [ "int3403_thermal" ];

  boot.initrd.luks.devices.root.device = "/dev/disk/by-uuid/c4a5062a-5060-4351-8f70-7cec63cd0487";
  fileSystems."/".device = "/dev/disk/by-uuid/87a61706-201f-469c-b399-490f83109760";
  fileSystems."/".fsType = "btrfs";
  fileSystems."/".options = [ "noatime" "nodiratime" "discard=async" "autodefrag" ];
  fileSystems."/boot".device = "/dev/disk/by-uuid/E7AF-1131";
  swapDevices = [{ device = "/dev/disk/by-uuid/c09b6f9b-c7ad-4672-91c2-895a40de81b5"; }];

  systemd.services.enable_fn_lock = {
    script = ''
      # Enable fn-lock
      echo 1 > /sys/devices/platform/lg-laptop/fn_lock

      #  fix high cpu on TB
      #echo unmask > /sys/firmware/acpi/interrupts/gpe6E
    '';
    wantedBy = [ "multi-user.target" ];
  };
}
