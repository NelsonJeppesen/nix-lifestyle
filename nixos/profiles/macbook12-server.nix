{ pkgs, config, ... }:

{
  # make this a server; dont sleep when laptop is closed
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  networking.wireless.enable = false;

  networking.networkmanager.enable = true;

  #systemd.services.console-fbset = {
  #  enable = true;
  #  serviceConfig = {
  #    Type = "oneshot";
  #    ExecStartPost = "${pkgs.util-linux}/bin/setterm -resize";
  #    ExecStartPre = "/run/current-system/sw/bin/sleep 15";
  #    ExecStart =
  #      "${pkgs.fbset}/bin/fbset -fb /dev/fb0 -g 2304 1440 2304 1440 32";
  #    TTYPath = "/dev/console";
  #    StandardOutput = "tty";
  #    StandardInput = "tty-force";
  #  };
  #  wantedBy = [ "multi-user.target" ];
  #  environment = { TERM = "linux"; };
  #};

  systemd.services.console-blank = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/setterm -blank 1 -powerdown 1";
      TTYPath = "/dev/console";
      StandardOutput = "tty";
    };
    wantedBy = [ "multi-user.target" ];
    environment = {
      TERM = "linux";
    };
  };
}
