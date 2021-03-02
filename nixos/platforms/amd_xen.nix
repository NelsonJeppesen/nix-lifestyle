{ config, pkgs, stdenv, lib, ... }:

{
  hardware.opengl.extraPackages = [ pkgs.amdvlk ];
  boot.kernelModules = [ "kvm-amd" "amdgpu"];

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC    = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT   = "powersave";
      DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
      SATA_LINKPWR_ON_AC            = "min_power";
      SATA_LINKPWR_ON_BAT           = "min_power";
      CPU_BOOST_ON_AC               = "1";
      CPU_BOOST_ON_BAT              = "0";
    };
  };
}
