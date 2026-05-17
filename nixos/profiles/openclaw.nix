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
      ExecStart = "${pkgs.openclaw}/bin/openclaw gateway";
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
  # logind alone is insufficient when a GNOME session is active —
  # gnome-settings-daemon's power plugin installs an inhibitor and takes
  # over lid handling, falling back to its own gsettings keys. Both layers
  # must be set to "ignore"/"nothing" or the lid will still suspend the
  # host on close.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.settings-daemon.plugins.power]
    lid-close-ac-action='nothing'
    lid-close-battery-action='nothing'
    sleep-inactive-ac-type='nothing'
    sleep-inactive-battery-type='nothing'
  '';
  services.desktopManager.gnome.extraGSettingsOverridePackages = [ pkgs.gnome-settings-daemon ];

  networking.firewall = {
    allowedTCPPorts = [
      22
      18789
    ];
  };
}
