{ config, pkgs, stdenv, lib,... }:

{
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
  ];

  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC               = "1";
      CPU_BOOST_ON_BAT              = "0";
      #CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MAX_PERF_ON_AC            = "100";
      CPU_MAX_PERF_ON_BAT           = "70";
      CPU_MIN_PERF_ON_BAT           = "0";
      CPU_SCALING_GOVERNOR_ON_AC    = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT   = "powersave";
      #DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
    };
  };

}
