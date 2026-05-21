# opencode.nix - `opencode serve` exposed over the tailnet via tailscale serve
#
# Mirrors profiles/openclaw.nix: a headless `opencode serve` bound to
# loopback, fronted by `tailscale serve` for HTTPS on the tailnet using
# Tailscale's per-tailnet cert. Tailnet ACLs are the only auth gate —
# opencode itself ships no built-in auth, same posture as the openclaw
# gateway.
#
# Why loopback + `tailscale serve` (instead of binding the tailnet IP)?
# - Direct tailnet bind works but exposes the API in plaintext on
#   tailscale0:4096 with no TLS termination.
# - `tailscale serve` keeps the API loopback-only, terminates TLS, and
#   piggybacks on tailscaled's identity / cert handling. PATH access to
#   `tailscale` is provided by profiles/tailscale.nix (must also be
#   imported by any machine using this profile).
#
# Identity:
# - The service runs as `nelson` (a normal user already provisioned by
#   profiles/shared.nix). We deliberately do NOT keep a dedicated
#   `opencode` system user any more — there's only one user on these
#   hosts, and routing the agent's git/gh/ssh access through nelson keeps
#   credentials and config in one place. HOME=/home/nelson lets opencode
#   pick up nelson's git config, ssh keys, and gh auth automatically.
# - opencode itself is configured via the home-manager module at
#   ../../home-manager/opencode.nix, loaded into nelson's user
#   environment by the home-manager NixOS module wired in below. That is
#   the SAME module nelson uses on his laptop, so the headless server
#   gets identical model selection, MCP servers, plugins, slash commands,
#   and global context.
#
# Notes:
# - On first launch the service has no model credentials in HOME. Either
#   drop a populated `~nelson/.local/share/opencode/auth.json` from a
#   trusted host, or run `sudo -iu nelson opencode auth login` once
#   during bootstrap.
# - Port 4096 is fixed (not 0 / random) so `tailscale serve` has a stable
#   upstream. If it ever needs to change, update both the ExecStart and
#   the ExecStartPost.
{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
let
  port = 4096;
in
{
  imports = [ home-manager.nixosModules.home-manager ];

  # Wire nelson's home-manager environment in via the NixOS module form.
  # We import ONLY the opencode module (not full home.nix) — this host is
  # headless and has no use for kitty/firefox/chrome/gnome/etc. The
  # opencode module renders ~/.config/opencode/opencode.json, installs
  # MCP server binaries into nelson's profile, and creates the memory
  # store directory.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    users.nelson = {
      imports = [ ../../home-manager/opencode.nix ];

      # Minimal home-manager identity for nelson. stateVersion is pinned
      # to 24.11 to match this host's system.stateVersion; bump only with
      # explicit migration intent.
      home.stateVersion = "24.11";
      home.username = "nelson";
      home.homeDirectory = "/home/nelson";

      # The opencode HM module declares `programs.zsh.shellAliases` and
      # an `initContent` snippet (`os` session picker). Those require
      # `programs.zsh.enable = true` at the home-manager layer, otherwise
      # they're silently ignored. Enable a minimal HM-managed zsh so the
      # aliases land in nelson's `~/.zshrc` (the system-wide zsh from
      # profiles/zsh.nix / shared.nix is unaffected).
      programs.zsh.enable = true;
    };
  };

  # Make the opencode binary available system-wide for diagnostics
  # (`sudo -iu nelson opencode auth login`, ad-hoc `opencode run …`, etc.).
  # The home-manager module already installs it into nelson's profile;
  # this just mirrors it into /run/current-system for convenience.
  environment.systemPackages = [ pkgs.opencode ];

  systemd.services.opencode = {
    description = "OpenCode serve (tailnet HTTPS via tailscale serve)";
    after = [
      "network-online.target"
      "tailscaled.service"
      # Ensure home-manager has activated nelson's profile (rendering
      # ~/.config/opencode/opencode.json) before the daemon starts.
      "home-manager-nelson.service"
    ];
    wants = [
      "network-online.target"
      "home-manager-nelson.service"
    ];
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
      #
      # `+` prefix = run as root regardless of User=. `tailscale serve`
      # talks to tailscaled's local API which is root-only, so the
      # `nelson` user can't publish the mapping itself.
      ExecStartPost = "+${pkgs.writeShellScript "opencode-tailscale-serve" ''
        set -eu
        ${pkgs.tailscale}/bin/tailscale serve --bg --https=443 http://127.0.0.1:${toString port} || true
      ''}";

      # Tear down the serve mapping on stop so a disabled unit doesn't
      # leave a stale 502 published on the tailnet. Also needs root.
      ExecStopPost = "+${pkgs.tailscale}/bin/tailscale serve --https=443 off";

      User = "nelson";
      Group = "users";

      WorkingDirectory = "/home/nelson";
      Environment = [ "HOME=/home/nelson" ];

      Restart = "always";
      RestartSec = 5;

      # Light sandboxing — opencode serve is an exposed network service
      # and shells out to `git`, model-provider CLIs, and MCP servers, so
      # we can't lock it down as hard as a pure binary.
      #
      # ProtectHome is intentionally OFF (was `true` under the old
      # dedicated-user setup): the service now runs as nelson and needs
      # to read ~/.config/opencode/opencode.json, ~/.gitconfig, ~/.ssh,
      # ~/.config/gh, etc. ProtectSystem=strict still keeps writes to
      # /usr, /etc, /boot blocked; the rest of nelson's $HOME is
      # writable as expected for a normal user session.
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ReadWritePaths = [ "/home/nelson" ];
    };
  };
}
