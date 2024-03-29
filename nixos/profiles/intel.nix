{ config, pkgs, stdenv, lib, ... }:

{
  # Use modern Intel iGPU with all the bells
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs;
    [
      intel-media-driver # hardware decode/encode of video streams
    ];

  # Update microcode when available
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Ensure modules used for efficent disk encryption are loaded
  # early in the boot process
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "aesni_intel" "cryptd" ];

  boot.kernelParams = [
    # reserve the frame-buffer as setup by the BIOS or bootloader to avoid any flickering until Xorg
    "i915.fastboot=1"
    "i915.modeset=1"

    # Making use of Framebuffer compression (FBC) can reduce power consumption while reducing memory bandwidth needed for screen refreshes
    "i915.enable_fbc=1"
    "i915.enable_psr=1"
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
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_MAX_PERF_ON_AC = "100";
    CPU_MAX_PERF_ON_BAT = "75";
    CPU_MIN_PERF_ON_BAT = "0";
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    SCHED_POWERSAVE_ON_BAT = "1";
    WOL_DISABLE = "Y";
  };
}
