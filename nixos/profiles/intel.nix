{
  pkgs,
  lib,
  ...
}:

{
  # Use modern Intel iGPU with all the bells
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-compute-runtime
    intel-media-driver # Intel iGPU (Gen9+ -> iHD)
    libva
    libva-utils # provides 'vainfo'
    libvdpau-va-gl # Fallbacks
    vaapiVdpau # VAAPI<->VDPAU bridge
    vpl-gpu-rt
  ];

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD"; # force modern VA-API
    MOZ_ENABLE_WAYLAND = "1"; # Firefox on Wayland behaves better/less wakeups
    OZONE_PLATFORM = "wayland";
  };

  # Update microcode when available
  hardware.cpu.intel.updateMicrocode = true;

  # Ensure modules used for efficient disk encryption are loaded
  # early in the boot process
  boot.initrd.kernelModules = [ "xe" ];

  boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
    "nvme"
    "sd_mod"
    "usb_storage"
    "xhci_pci"
  ];

  #networking.networkmanager.wifi.powersave = true;

  # Enable TLP service to reduce power usage and fan noise, particularly on battery
  services.thermald.enable = lib.mkDefault true;
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = lib.mkDefault true;
  services.tlp.settings = {
    PLATFORM_PROFILE_ON_AC = "low-power";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    MEM_SLEEP_ON_AC = "deep";

    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "power";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_MIN_PERF_ON_AC = 25;
    CPU_MAX_PERF_ON_AC = 100;
    CPU_MIN_PERF_ON_BAT = 5;
    CPU_MAX_PERF_ON_BAT = 70;
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;
    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;

    NMI_WATCHDOG = 0;

    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";

    NVME_APST_ON_AC = 1;
    NVME_APST_ON_BAT = 1;
    NVME_APST_MAX_LATENCY_ON_AC = 70000;
    NVME_APST_MAX_LATENCY_ON_BAT = 55000;

    SATA_LINKPWR_ON_AC = "min_power";
    SATA_LINKPWR_ON_BAT = "min_power";
    AHCI_RUNTIME_PM_ON_AC = "auto";
    AHCI_RUNTIME_PM_ON_BAT = "auto";
    AHCI_RUNTIME_PM_TIMEOUT = 15;

    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "off";
    WOL_DISABLE = "Y";

    USB_AUTOSUSPEND = 1;
    USB_DENYLIST_BTUSB = 1;
    USB_EXCLUDE_PHONE = 1;

    SOUND_POWER_SAVE_ON_AC = 0;
    SOUND_POWER_SAVE_ON_BAT = 10;
    SOUND_POWER_SAVE_CONTROLLER = "Y";

    RUNTIME_PM_ON_AC = "auto";
    RUNTIME_PM_ON_BAT = "auto";
  };
}
