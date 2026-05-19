# openclaw — stationary LG Gram running the openclaw gateway service.
# Managed remotely via comin (see profiles/comin.nix); manual rebuilds are
# only needed for the initial bootstrap.
#
# `laptop_power.nix` is intentionally NOT imported: this host is always on
# AC, and TLP's powersave defaults trade gateway responsiveness for ~1W of
# savings we don't care about here.
{ ... }:
{
  system.stateVersion = "26.05";

  imports = [
    ../profiles/comin.nix
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_common.nix
    ../profiles/networking.nix
    ../profiles/openclaw.nix
    ../profiles/tailscale.nix
    ../profiles/wifi.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  # Stationary always-on gateway sitting in the overlap zone of two APs on the
  # same SSID. With NetworkManager's default wpa_supplicant backend the host
  # ping-pongs between BSSIDs every few minutes (see journal: repeated
  # "disconnect from AP X for new auth to Y"). Switch to iwd, which roams
  # more conservatively, and disable periodic scans + radio power-save since
  # neither buys us anything on an AC-powered host.
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.settings = {
    General.EnableNetworkConfiguration = false;
    Scan.DisablePeriodicScan = true;
    DriverQuirks.DefaultPowerSave = false;
  };

  # Belt-and-braces: keep the iwlwifi radio out of power-save regardless of
  # what userspace asks for. Matches the AX211/BE200 tuning on the LG Gram
  # Pro 17 2025 — same chip family lives in this Gram too.
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 uapsd_disable=1
    options iwlmvm power_scheme=1
  '';
}
