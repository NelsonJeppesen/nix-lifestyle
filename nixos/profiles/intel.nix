{ config, pkgs, stdenv, lib,... }:

{
  # Use modern Intel iGPU with all the bells
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;

  # Update microcode when available
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Ensure modules used for efficent disk encryption are loaded
  # early in the boot process
  boot.initrd.availableKernelModules = ["aesni_intel" "cryptd"];

  # Enable TLP service to reduce power usage, particularly on battery
  #
  # Always disable turbo boost
  # Run at 70% speed on battery and 90% on ac
  services.tlp.enable = true;
  services.tlp.settings = {
    CPU_BOOST_ON_AC               = "0";
    CPU_BOOST_ON_BAT              = "0";
    CPU_MAX_PERF_ON_AC            = "90";
    CPU_MAX_PERF_ON_BAT           = "70";
    CPU_MIN_PERF_ON_BAT           = "0";
    CPU_SCALING_GOVERNOR_ON_AC    = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT   = "powersave";
    USB_WHITELIST                 = "27c6:6a94";
    #DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
  };

}
