{
  pkgs,
  ...
}:

{
  # Use modern Intel iGPU with all the bells
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-compute-runtime # OpenCL for compute workloads
    intel-media-driver # Intel iGPU (Gen9+ -> iHD)
    libva
    libva-utils # provides 'vainfo'
    vpl-gpu-rt # Intel VPL for modern video codecs
  ];

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD"; # force modern VA-API
    MOZ_ENABLE_WAYLAND = "1"; # Firefox on Wayland behaves better/less wakeups
    OZONE_PLATFORM = "wayland";
  };
  # Enable Firefox hardware video decode
  environment.sessionVariables = {
    MOZ_X11_EGL = "1"; # Enable EGL for X11 sessions
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

  # NOTE: TLP, thermald, power-profiles-daemon, and the iwd Wi-Fi backend
  # were moved to profiles/laptop_power.nix so Intel desktops/NUCs no longer
  # inherit battery-oriented defaults. Each laptop machine imports
  # laptop_power.nix explicitly.
}
