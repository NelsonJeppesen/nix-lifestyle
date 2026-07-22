# Stationary LG Gram repurposed as a headless deployment server.
# Managed remotely via comin; SSH and services are reachable over Tailscale.
{ lib, ... }:
{
  system.stateVersion = "26.05";

  imports = [
    ../profiles/comin.nix
    ../profiles/console.nix
    ../profiles/headless-server.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_common.nix
    ../profiles/networking.nix
    ../profiles/tailscale.nix
    ../profiles/x86_64.nix
  ];

  networking.networkmanager.enable = true;

  # Trust all traffic from private IPv4 networks. Tailnet traffic is allowed
  # separately by the trusted tailscale0 interface.
  networking.firewall = {
    allowedTCPPorts = [ 22 ];
    allowedTCPPortRanges = lib.mkForce [ ];
    allowedUDPPortRanges = lib.mkForce [ ];
    extraInputRules = ''
      ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept
    '';
  };
  networking.nftables.enable = true;

  # Stationary always-on gateway sitting in the overlap zone of two APs on the
  # same SSID. With NetworkManager's default wpa_supplicant backend the host
  # ping-pongs between BSSIDs every few minutes (see journal: repeated
  # "disconnect from AP X for new auth to Y"). Switch to iwd, which roams
  # more conservatively by default.
  #
  # Notes on iwd settings we are NOT applying:
  # - `Scan.DisablePeriodicScan = true` looks tempting on a stationary host
  #   ("we're already connected, why keep scanning?") but it also prevents
  #   iwd from discovering any SSID while disconnected, so the GNOME Wi-Fi
  #   list comes up empty after boot until something else (a known network
  #   appearing, a user-triggered scan) wakes scanning back up. Leave it at
  #   the default (periodic scan enabled).
  # - The often-cited `DriverQuirks.DefaultPowerSave = false` is not a real
  #   iwd option (the key in `iwd.config(5)` is `PowerSaveDisable`, and it
  #   expects a comma-separated driver glob, not a boolean). Radio power-save
  #   is handled by the iwlwifi modprobe options below instead.
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.settings = {
    General.EnableNetworkConfiguration = false;
  };

  # Belt-and-braces: keep the iwlwifi radio out of power-save regardless of
  # what userspace asks for. Matches the AX211/BE200 tuning on the LG Gram
  # Pro 17 2025 — same chip family lives in this Gram too.
  #
  # `cfg80211 ieee80211_regdom=US` pins the regulatory domain at module load
  # time. Without it the kernel relies on country IEs from beacons, and the
  # local APs broadcast a `US 4` triplet (6 GHz UNII-5 LPI, operating class
  # 137) that cfg80211 fails to parse:
  #
  #   cfg80211: failed to find band with country string 'us 4' and oper class 137
  #
  # On failure cfg80211 drops the offending BSS entries entirely, so iwd's
  # scan results come back empty and GNOME's Wi-Fi list shows no networks
  # at all (not just no 6 GHz ones). Pinning the regdomain to US skips the
  # country-IE parsing path and restores 2.4/5 GHz discovery.
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    # Pin regdomain at module load (see comment block above).
    options cfg80211 ieee80211_regdom=US
    options iwlwifi power_save=0 uapsd_disable=1
    options iwlmvm power_scheme=1
  '';
}
