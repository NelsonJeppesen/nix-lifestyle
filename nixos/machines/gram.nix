#
# LG Gram 17" 20201 (17Z90P K.AAB8U1)
#
{ config, pkgs, stdenv, lib, modulesPath, ... }:

{
  # Enable fingerprint reader for login but not sudo
  services.fprintd.enable = true;
  security.pam.services.sudo.fprintAuth = false;

  # I forked libfprint to add support for this laptop
  # Waiting on two things
  # 1. nixpkgs to use latest fprint release
  # 2. libfprint to merge my PR
  nixpkgs.overlays = [(
  self: super:
  {
    libfprint = super.libfprint.overrideAttrs (old: {
      pname = "libfprint";
      version = "1.90.9";
      outputs = [ "out" "devdoc" ];
      src = super.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "NelsonJeppesen";
        repo = "libfprint";
        rev = "67ff412e8c53d686dfb337412c2da9befab3e56a";
        sha256 = "036z9nn6fzy3w6hcyab67qw22mam5mcscinpjsiylrmrki6g8kkl";
      };
    });
  }
  )];

  networking.hostName = "gram";

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../profiles/x86_64.nix
    ../profiles/intel.nix
    ../profiles/shared.nix
    ../profiles/desktop.nix
  ];

  systemd.services.fix-suspend = {
    script = ''
      # Enable fn-lock
      echo 1 > /sys/devices/platform/lg-laptop/fn_lock
    '';
    wantedBy = [ "multi-user.target" ];
  };

# boot.kernelPatches = [{
#   name = "crashdump-config";
#   patch = null;
#   extraConfig = ''
#  	CONFIG_SND_SOC_SOF_INTEL_SOUNDWIRE m
#  	SND_SOC_INTEL_SOUNDWIRE_SOF_MACH m
#         '';
# }];


  boot.kernelParams = [
    "i915.modeset=1"
    "i915.fastboot=1"
    "i915.enable_fbc=1"
    #"snd_hda_intel.dmic_detect=0"
    #"i915.enable_gvt=1"
    #"i915.enable_psr=1"
  ];

  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.gfxmodeEfi = "1024x768";

  boot.extraModprobeConfig = ''
    #options snd-hda-intel model=alc298-dell-aio
    options snd_hda_intel power_save=2
    #options snd_intel_dspcfg dsp_driver=3
    #options snd-hda-intel model=dual-codecs
  '';

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/43c7d480-0c9d-4cd6-9dad-086b67b79440";
      fsType = "xfs";
    };

  boot.initrd.luks.devices."crypt".device = "/dev/disk/by-uuid/e5587b91-ce02-45b1-b570-d925b9345fc7";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/FA89-9F6E";
      fsType = "vfat";
    };

  hardware.video.hidpi.enable = lib.mkDefault true;
}
