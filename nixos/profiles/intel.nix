{ config, pkgs, stdenv, lib, ... }:

{
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
  ];

  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_AC               = "1";
      CPU_BOOST_ON_BAT              = "0";
      #CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MAX_PERF_ON_AC            = "100";
      CPU_MAX_PERF_ON_BAT           = "70";
      CPU_MIN_PERF_ON_BAT           = "0";
      CPU_SCALING_GOVERNOR_ON_AC    = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT   = "powersave";
      #DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
    };

  };

#nixpkgs.overlays = [(
#
#self: super:
#{
#  sof-firmware = super.sof-firmware.overrideAttrs (old: {
#  version = "1.6.1";
#    src = super.fetchFromGitHub {
#      owner = "thesofproject";
#      repo = "sof-bin";
#      rev = "b77c851bc4ec1b6b552eaf1a61a66f3df4a13ab8";
#      sha256 = "172mlnhc7qvr65v2k1541inasm5hwsibmqqmpapml5n2a4srx7nr";
#    };
#  installPhase = ''
#    mkdir -p $out/lib/firmware
#    patchShebangs go.sh
#    ROOT=$out SOF_VERSION=v1.6.1 ./go.sh
#  '';
#  });
#}
#)];

}
