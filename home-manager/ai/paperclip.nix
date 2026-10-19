{
  config,
  lib,
  pkgs,
  paperclip,
  ...
}:
let
  paperclipPackage = pkgs.callPackage ./paperclip/package.nix { inherit paperclip; };
  paperclipHome = "${config.home.homeDirectory}/.paperclip";

  paperclipRun = pkgs.writeShellApplication {
    name = "paperclip-run";
    text = ''
      # Automated onboarding saves local defaults, generates secrets outside
      # the Nix store, and starts the server in this same foreground process.
      if [ ! -f "${paperclipHome}/instances/default/config.json" ]; then
        exec ${lib.getExe paperclipPackage} onboard --yes --no-install-service
      fi
      exec ${lib.getExe paperclipPackage} run --instance default
    '';
  };
in
{
  # Keep the CLI on a stable path alongside the other agent launchers.
  home.file.".local/bin/paperclipai".source = "${paperclipPackage}/bin/paperclipai";

  # User lingering is already enabled on this laptop, so default.target also
  # starts at boot and keeps the service running after logout.
  systemd.user.services.paperclipai = {
    Unit = {
      Description = "Paperclip AI agent management";
      After = [ "network.target" ];
      StartLimitIntervalSec = 0;
    };

    Service = {
      ExecStart = lib.getExe paperclipRun;
      WorkingDirectory = config.home.homeDirectory;
      Environment = [
        "PAPERCLIP_HOME=${paperclipHome}"
        "PAPERCLIP_INSTANCE_ID=default"
        "PAPERCLIP_SERVICE_MANAGED=1"
        "PAPERCLIP_NO_BROWSER=true"
        "HOST=127.0.0.1"
        "PORT=3100"
        # Keep the installed agent CLIs available outside an interactive shell.
        "PATH=${
          lib.makeBinPath [
            pkgs.nodejs_24
            pkgs.git
            pkgs.openssh
            pkgs.bash
            pkgs.coreutils
          ]
        }:${config.home.profileDirectory}/bin:${config.home.homeDirectory}/.local/bin:/run/current-system/sw/bin"
      ];
      Restart = "always";
      RestartSec = 5;
      TimeoutStopSec = 300;
      UMask = "0077";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
