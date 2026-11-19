# intel.nix - Intel iGPU + CPU baseline (modesetting, VA-API, microcode)
#
# Battery-tuned bits (TLP, thermald, iwd, etc.) live in laptop_power.nix
# so this profile is safe to import on Intel desktops/NUCs as well.
{ pkgs, ... }: {
  # Use the generic Xorg modesetting driver and Intel video/compute runtimes.
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

  # The KMS driver (xe or i915) differs per host, so each machine file picks
  # it: force_probe, blacklist and boot.initrd.kernelModules. Loading it in
  # initrd lets Plymouth start on the real KMS driver instead of flipping
  # from simpledrm mid-boot.

  boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
    "nvme"
    "sd_mod"
    "usb_storage"
    "xhci_pci"
  ];

}
