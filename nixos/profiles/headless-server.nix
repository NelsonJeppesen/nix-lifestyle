{ lib, pkgs, ... }:
{
  systemd.defaultUnit = "multi-user.target";

  services = {
    fwupd.enable = lib.mkForce false;
    keyd.enable = lib.mkForce false;
    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
    upower.enable = lib.mkForce false;
    xserver.enable = lib.mkForce false;
  };

  # Blank the laptop panel when it is only being used as a remote server.
  systemd.services.console-blank = {
    description = "Blank the local console";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.util-linux}/bin/setterm -blank 1 -powerdown 1";
      TTYPath = "/dev/console";
      StandardOutput = "tty";
    };
    environment.TERM = "linux";
  };
}
