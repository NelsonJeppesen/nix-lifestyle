# openclaw.nix - openclaw gateway service + dedicated system user
#
# Runs `openclaw gateway` as a system service under a dedicated `openclaw`
# user. The gateway binds to loopback (127.0.0.1:18789) and `tailscale serve`
# fronts it with HTTPS on the tailnet, injecting tailscale identity headers
# (`tailscale-user-login`) so Control UI/WS clients on the tailnet authenticate
# without a shared token. Per upstream docs (docs/gateway/remote.md) this is
# the preferred "always-on gateway in a tailnet" deployment. Lid-switch ignores
# keep the host running when the laptop lid is closed (always-on deployment).
#
# Why not `--bind=tailnet` (prior config)?
# - Direct tailnet bind works, but exposes the gateway on tailscale0:18789
#   in plaintext ws:// with no HTTPS termination and no identity headers, so
#   it relies on a shared token for auth.
# - `tailscale serve` keeps the gateway loopback-only, terminates TLS via
#   Tailscale's per-tailnet HTTPS cert, and gives us tokenless identity auth
#   for the Control UI + WebSocket. PATH access to `tailscale` is provided
#   by profiles/tailscale.nix.
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
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    # `tailscale` must be on PATH so openclaw can invoke `tailscale serve`
    # and `tailscale whois` for identity-header verification.
    path = [ pkgs.tailscale ];

    serviceConfig = {
      # `--tailscale serve` keeps gateway.bind at its loopback default and
      # asks openclaw to configure `tailscale serve` for the Control UI +
      # WebSocket. Combined with the gateway's `allowTailscale` default,
      # tailnet peers authenticate via tailscale identity headers — no
      # shared token required for Control UI/WS access.
      ExecStart = "${pkgs.openclaw}/bin/openclaw gateway --tailscale serve";
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

  # Only SSH is exposed on the public firewall. The gateway binds to
  # loopback only; `tailscale serve` proxies tailnet traffic in-process
  # via tailscaled, so no extra TCP port needs opening here. Tailnet peers
  # still have full access via the trusted tailscale0 interface declared
  # in profiles/tailscale.nix.
  networking.firewall = {
    allowedTCPPorts = [
      22
    ];
  };
}
