# openclaw.nix - openclaw gateway service + dedicated system user
#
# Runs `openclaw gateway` as a system service under a dedicated `openclaw`
# user. Listens on TCP/18789. Lid-switch ignores keep the host running when
# the laptop lid is closed (this is a stationary always-on deployment).
#
# Notes:
# - HOME is forced to /var/lib/openclaw (managed by systemd's StateDirectory)
#   so the service no longer depends on /home/openclaw being created at first
#   login. Previously the missing home dir caused the unit to silently no-op
#   until someone logged in graphically and triggered home creation.
# - The insecure-package allowlist tracks `pkgs.openclaw.name` instead of a
#   hardcoded version string, so it doesn't go stale on every upstream bump.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  users.users.openclaw = {
    isSystemUser = true;
    group = "openclaw";
    extraGroups = [ "docker" ];
    description = "OpenClaw gateway service account";
  };
  users.groups.openclaw = { };

  environment.systemPackages = [ pkgs.openclaw ];

  # Upstream openclaw ships with known CVEs (see
  # nixpkgs.knownVulnerabilities). Allowlist by computed name so version
  # bumps don't require touching this file.
  nixpkgs.config.permittedInsecurePackages = [ pkgs.openclaw.name ];

  systemd.services.openclaw = {
    description = "OpenClaw Gateway";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      # --bind=tailnet listens only on the tailscale0 interface. Combined
      # with trustedInterfaces in profiles/tailscale.nix, this makes the
      # gateway reachable from any tailnet peer without exposing 18789 on
      # the LAN or wider internet.
      ExecStart = "${pkgs.openclaw}/bin/openclaw gateway --bind=tailnet";
      User = "openclaw";
      Group = "openclaw";

      # systemd creates /var/lib/openclaw owned by openclaw:openclaw on
      # every start — no manual mkdir, no /home/openclaw, no login required.
      StateDirectory = "openclaw";
      StateDirectoryMode = "0750";
      WorkingDirectory = "/var/lib/openclaw";
      Environment = [ "HOME=/var/lib/openclaw" ];

      Restart = "on-failure";
      RestartSec = 5;

      # Light sandboxing — openclaw is an exposed network service.
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ReadWritePaths = [ "/var/lib/openclaw" ];
    };
  };

  # Stationary deployment: never sleep on lid close, regardless of power.
  #
  # GNOME 49+ removed lid-close-*-action from gnome-settings-daemon and
  # delegates lid handling back to logind, so HandleLidSwitch=ignore is
  # again authoritative. We still pin GSD's idle-suspend keys to 'nothing'
  # so an idle GNOME session can't suspend the box on its own.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    sleep-inactive-ac-type='nothing'
    sleep-inactive-battery-type='nothing'
  '';
  services.desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.gnome-settings-daemon ];

  # Only SSH is exposed on the public firewall; the gateway port (18789)
  # is reached via tailscale0, which profiles/tailscale.nix marks as a
  # trusted interface (all ports permitted on the tailnet).
  networking.firewall = {
    allowedTCPPorts = [
      22
    ];
  };
}
