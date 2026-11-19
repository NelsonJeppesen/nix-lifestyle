# LG Gram 14 2022 14Z90Q-K.ARW5U1 Intel 12th Gen
{ ... }:
{
  # Compatibility defaults for stateful services; do not bump during upgrades.
  system.stateVersion = "25.05";

  # Installation target. Verify the physical disk and replace this with its
  # /dev/disk/by-id identity on the 2022 host before any destructive install.
  disko.devices.disk.vdb.device = "/dev/nvme0n1";

  imports = [
    ../profiles/chrome-policies.nix
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/laptop_power.nix
    ../profiles/lg_gram_common.nix
    ../profiles/networking.nix
    ../profiles/plymouth.nix
    ../profiles/s3fs.nix
    ../profiles/storage-maintenance.nix
    ../profiles/scanner.nix
    ../profiles/tailscale.nix
    ../profiles/x86_64.nix
  ];

  # GPU: `xe` for the Alder Lake iGPU (46a6); i915 is kept off the device.
  boot.kernelParams = [
    "xe.force_probe=46a6"
    "i915.force_probe=!46a6"
    # "acpi.ec_no_wakeup=1"
    "acpi_mask_gpe=0x6e"
  ];

  boot.blacklistedKernelModules = [ "i915" ];
  boot.initrd.kernelModules = [ "xe" ];

  # 8GiB laptop; things get tight
  zramSwap.memoryPercent = 80;

  # Build one derivation at a time. With only 8GiB, parallel builds (default
  # max-jobs = "auto" = nproc) race for RAM during `update` and OOM. Serializing
  # trades build throughput for staying alive; `--cores` is left at default so a
  # single derivation still uses all CPUs. Daemon-wide, so it also covers the
  # user layer's `nh home switch` (which builds via the same daemon).
  nix.settings.max-jobs = 1;
}
