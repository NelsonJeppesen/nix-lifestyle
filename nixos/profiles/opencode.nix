# opencode.nix - `opencode serve` exposed over the tailnet via tailscale serve
#
# Mirrors profiles/openclaw.nix: a dedicated system user runs `opencode serve`
# bound to loopback, and `tailscale serve` fronts it with HTTPS on the
# tailnet using Tailscale's per-tailnet cert. Tailnet ACLs are the only
# auth gate — opencode itself ships no built-in auth, same posture as the
# openclaw gateway.
#
# Why loopback + `tailscale serve` (instead of binding the tailnet IP)?
# - Direct tailnet bind works but exposes the API in plaintext on
#   tailscale0:4096 with no TLS termination.
# - `tailscale serve` keeps the API loopback-only, terminates TLS, and
#   piggybacks on tailscaled's identity / cert handling. PATH access to
#   `tailscale` is provided by profiles/tailscale.nix (must also be
#   imported by any machine using this profile).
#
# Notes:
# - HOME is forced to /var/lib/opencode (managed by systemd's StateDirectory)
#   so opencode's auth/session storage is persistent and isolated from
#   /home/nelson. The home-manager opencode config is user-scoped and does
#   NOT apply to this service account; on first launch the service has no
#   model credentials. Drop a `~opencode/.local/share/opencode/auth.json`
#   (or run `sudo -u opencode opencode auth login`) once during bootstrap.
# - Port 4096 is fixed (not 0 / random) so `tailscale serve` has a stable
#   upstream. If it ever needs to change, update both the ExecStart and
#   the ExecStartPost.
{
  config,
  pkgs,
  lib,
  ...
}:
let
  port = 4096;
in
{
  users.users.opencode = {
    isSystemUser = true;
    group = "opencode";
    description = "OpenCode serve service account";
    # Real shell + home so `sudo -iu opencode` works for diagnostics
    # (auth login, MCP server testing, etc.). The service itself uses
    # StateDirectory + Environment=HOME=… below.
    home = "/var/lib/opencode";
    createHome = true;
    shell = pkgs.bashInteractive;
  };
  users.groups.opencode = { };

  environment.systemPackages = [ pkgs.opencode ];

  systemd.services.opencode = {
    description = "OpenCode serve (tailnet HTTPS via tailscale serve)";
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [ "network-online.target" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];

    # `tailscale` must be on PATH so the post-start hook can publish the
    # serve config.
    path = [ pkgs.tailscale ];

    serviceConfig = {
      ExecStart = "${pkgs.opencode}/bin/opencode serve --hostname 127.0.0.1 --port ${toString port}";

      # Publish the serve config on every start; idempotent because
      # `tailscale serve` overwrites any prior mapping for the same
      # source/target. The `|| true` keeps a transient tailscaled
      # hiccup from holding the unit down — opencode itself is healthy.
      ExecStartPost = pkgs.writeShellScript "opencode-tailscale-serve" ''
        set -eu
        ${pkgs.tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:${toString port} || true
      '';

      # Tear down the serve mapping on stop so a disabled unit doesn't
      # leave a stale 502 published on the tailnet.
      ExecStopPost = "${pkgs.tailscale}/bin/tailscale serve --https=443 off";

      User = "opencode";
      Group = "opencode";

      # systemd creates /var/lib/opencode owned by opencode:opencode on
      # every start — no manual mkdir, no /home/opencode, no login required.
      StateDirectory = "opencode";
      StateDirectoryMode = "0750";
      WorkingDirectory = "/var/lib/opencode";
      Environment = [ "HOME=/var/lib/opencode" ];

      Restart = "always";
      RestartSec = 5;

      # Light sandboxing — opencode serve is an exposed network service
      # and shells out to `git`, model-provider CLIs, and MCP servers, so
      # we can't lock it down as hard as a pure binary. ProtectHome is
      # safe because the service's own home lives under /var/lib/opencode
      # (covered by ReadWritePaths).
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ReadWritePaths = [ "/var/lib/opencode" ];
    };
  };
}
