{
  config,
  lib,
  pkgs,
  herdr-remote,
  ...
}:
let
  # Hostnames to tunnel labels (same scheme as opencode.nix).
  relayHostLabels = {
    "lg-gram-14-2022" = "lg-gram-14";
    "lg-gram-pro-17-2025" = "lg-gram-17";
  };
  relayLabelPairs = lib.concatStringsSep " " (
    lib.mapAttrsToList (host: label: "[${host}]=${label}") relayHostLabels
  );

  configDir = "${config.home.homeDirectory}/.config/herdr-remote";

  # Upstream runs the relay through `uv run` (PEP 723 deps resolved at start);
  # nixpkgs carries every dependency, so pin them here instead.
  relayPython = pkgs.python3.withPackages (
    ps: with ps; [
      websockets
      zeroconf
      pywebpush
      py-vapid
    ]
  );

  # The relay serves the dashboard from ../web relative to herdr_relay.py,
  # so keep both directories side by side.
  herdrRemote = pkgs.runCommand "herdr-remote-0.8.0" { } ''
    mkdir -p $out/share/herdr-remote
    cp -r ${herdr-remote}/relay ${herdr-remote}/web $out/share/herdr-remote/
  '';

  relayRun = pkgs.writeShellApplication {
    name = "herdr-remote-relay";
    runtimeInputs = [
      pkgs.herdr
      pkgs.openssh # HERDR_REMOTES polls other hosts over ssh
    ];
    text = ''
      export HERDR_BIN="${lib.getExe pkgs.herdr}"
      export HERDR_RELAY_HOST="''${HERDR_RELAY_HOST:-127.0.0.1}"
      export HERDR_RELAY_PORT="''${HERDR_RELAY_PORT:-8375}"
      export HERDR_LOG_DIR="''${HERDR_LOG_DIR:-${config.xdg.stateHome}/herdr-remote/log}"
      exec ${lib.getExe relayPython} ${herdrRemote}/share/herdr-remote/relay/herdr_relay.py "$@"
    '';
  };

  tuiRun = pkgs.writeShellApplication {
    name = "herdr-remote-tui";
    text = ''
      exec ${lib.getExe relayPython} ${herdrRemote}/share/herdr-remote/relay/herdr_tui.py "$@"
    '';
  };
in
{
  home.packages = [
    relayRun
    tuiRun
  ];

  # Loopback relay + web dashboard on :8375, behind Cloudflare Access.
  # Optional ~/.config/herdr-remote/secrets.env (mode 0600) holds:
  #   HERDR_TRUSTED_ORIGINS=https://<access-hostname>  (required via the tunnel)
  #   HERDR_RELAY_TOKEN=<openssl rand -hex 32>         (defence in depth)
  #   HERDR_REMOTES=user@host,...                      (extra herdr hosts)
  systemd.user.services.herdr-remote-relay = {
    Unit = {
      Description = "herdr-remote relay and web dashboard";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      ExecStart = lib.getExe relayRun;
      EnvironmentFile = "-${configDir}/secrets.env";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };

  # Run the tunnel with the matching host token.
  systemd.user.services.herdr-remote-tunnel = {
    Unit = {
      Description = "Cloudflare Tunnel for the herdr-remote relay";
      After = [
        "network-online.target"
        "herdr-remote-relay.service"
      ];
      Wants = [
        "network-online.target"
        "herdr-remote-relay.service"
      ];
    };

    Service =
      let
        tokenDir = "${configDir}/cloudflared";
        run = pkgs.writeShellApplication {
          name = "herdr-remote-tunnel-run";
          runtimeInputs = [ pkgs.cloudflared ];
          text = ''
            declare -A labels=(${relayLabelPairs})
            host="$(hostname)"
            label="''${labels[$host]:-}"
            if [ -z "$label" ]; then
              echo "herdr-remote-tunnel: host '$host' runs no tunnel; nothing to do." >&2
              exit 0
            fi
            token_file="${tokenDir}/token.$label"
            if [ ! -r "$token_file" ]; then
              echo "herdr-remote-tunnel: token for '$label' missing at $token_file." >&2
              exit 1
            fi
            exec cloudflared tunnel --no-autoupdate run --token "$(cat "$token_file")"
          '';
        };
      in
      {
        ExecStart = lib.getExe run;
        Restart = "on-failure";
        RestartSec = 5;
      };

    Install.WantedBy = [ "default.target" ];
  };
}
