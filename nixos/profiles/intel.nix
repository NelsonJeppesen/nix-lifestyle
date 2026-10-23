# intel.nix - Intel iGPU + CPU baseline (modesetting, VA-API, microcode)
#
# Battery-tuned bits (TLP, thermald, iwd, etc.) live in laptop_power.nix
# so this profile is safe to import on Intel desktops/NUCs as well.
{ pkgs, ... }: {
  # Use modern Intel iGPU with all the bells
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-compute-runtime # OpenCL for compute workloads
    intel-media-driver # Intel iGPU (Gen9+ -> iHD)
    libva
    vpl-gpu-rt # Intel VPL for modern video codecs
  ];

  # extraPackages only reach /run/opengl-driver, so tools go on PATH here.
  environment.systemPackages = [ pkgs.libva-utils ]; # vainfo

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD"; # force modern VA-API
    OZONE_PLATFORM = "wayland";
  };
  # Update microcode when available
  hardware.cpu.intel.updateMicrocode = true;

  # Every host drives its iGPU with `xe` (each machine file sets its
  # force_probe ID). Loading it in initrd lets Plymouth start on the real KMS
  # driver instead of flipping from simpledrm mid-boot.
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
