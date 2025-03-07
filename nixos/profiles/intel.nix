{
  config,
  pkgs,
  stdenv,
  lib,
  ...
}:

{
  # Use modern Intel iGPU with all the bells
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # hardware decode/encode of video streams
    intel-vaapi-driver
    libvdpau-va-gl
  ];

  environment.variables = {
    VDPAU_DRIVER = "va_gl";
  };

  # Update microcode when available
  hardware.cpu.intel.updateMicrocode = true;

  # Ensure modules used for efficent disk encryption are loaded
  # early in the boot process
  boot.initrd.kernelModules = [ "i915" ];

  boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
    "nvme"
    "sd_mod"
    "usb_storage"
    "xhci_pci"
  ];

  boot.kernelParams = [
    "i915.modeset=1"

    # Making use of Framebuffer compression (FBC) can reduce power consumption while reducing memory bandwidth needed for screen refreshes
    "i915.enable_fbc=1"
    "i915.enable_psr=2"
    "i915.enable_dc=1"
  ];

  # Enable TLP service to reduce power usage and fan noise, particularly on battery
  #services.thermald.enable = lib.mkDefault true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = lib.mkDefault true;
  services.tlp.settings = {
    CPU_BOOST_ON_AC = "0";
    CPU_BOOST_ON_BAT = "0";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    CPU_HWP_DYN_BOOST_ON_AC = "0";
    CPU_HWP_DYN_BOOST_ON_BAT = "0";
    CPU_MAX_PERF_ON_AC = "100";
    CPU_MAX_PERF_ON_BAT = "70";
    PLATFORM_PROFILE_ON_AC = "balanced";
    PLATFORM_PROFILE_ON_BAT = "balanced";
    RUNTIME_PM_ON_AC = "auto";
    RUNTIME_PM_ON_BAT = "auto";
    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "off";
  };
}
