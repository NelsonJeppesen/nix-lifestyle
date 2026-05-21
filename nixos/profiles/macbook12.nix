# macbook12.nix - Apple MacBook 12 (Retina, A1534) hardware quirks
#
# Imported by every macbook12-* machine. Two concerns live here:
#
# 1. initrd modules required to bring the SSD + applespi keyboard up
#    early enough for stage-2 to take over.
#
# 2. Console (TTY) tuning for the 2304x1440 12" retina panel.
#
# About the console cutoff
# ------------------------
# At native 2304x1440 with the kernel default 8x16 console font the
# framebuffer console computes ~90 rows tall, but the i915/xe handoff
# from EFI on this panel ends up scaling/positioning the framebuffer
# such that the bottom 2-4 rows render off-screen. The fix is two
# layered changes:
#
# (a) Pin the framebuffer mode at module load with a `video=` kernel
#     param. eDP-1 1920x1200@60 is a clean mode the panel scales
#     cleanly and gives the kernel a deterministic geometry instead
#     of whatever EFI handed off.
#
# (b) Use a HiDPI-readable terminus font (`ter-v32n`, 16x32 px). On a
#     1920x1200 framebuffer this gives ~37 rows × 120 cols — readable
#     across the room and well within the visible area, so the
#     truncated-bottom symptom disappears regardless of any residual
#     handoff weirdness.
#
# `console.earlySetup` is already enabled by profiles/shared.nix
# (mkDefault true), which is what makes the font apply in initrd
# rather than only after stage-2.
#
# Hosts that don't want this (e.g. running headless with a serial
# console) can override `console.font` and `boot.kernelParams` per
# machine; both keys here use mkDefault.
{ lib, pkgs, ... }:
{
  boot.initrd.availableKernelModules = [
    "applespi"
    "intel_lpss_pci"
    "mac_hid"
    "nvme"
    "sd_mod"
    "spi_pxa2xx_platform"
    "usb_storage"
    "usbcore"
    "xhci_pci"
  ];

  # See header (a): pin the framebuffer mode so the console geometry
  # is deterministic on first boot. Appended to existing kernelParams
  # via mkAfter so we don't fight desktop.nix's `quiet`/`splash` set.
  boot.kernelParams = lib.mkAfter [ "video=eDP-1:1920x1200@60" ];

  # See header (b): HiDPI console font from terminus.
  console.font = lib.mkDefault "ter-v32n";
  console.packages = [ pkgs.terminus_font ];
  console.earlySetup = lib.mkDefault true;
}
