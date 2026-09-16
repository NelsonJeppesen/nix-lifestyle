{
  config,
  pkgs,
  flameshot,
  ...
}:
let
  flameshotScreenshot = pkgs.writeShellApplication {
    name = "flameshot-screenshot";
    runtimeInputs = [ pkgs.procps ];
    text = ''
      pkill -f '/bin/[f]lameshot( |$)' || true
      while pgrep -f '/bin/[f]lameshot( |$)' >/dev/null; do
        sleep 0.05
      done
      exec ${config.services.flameshot.package}/bin/flameshot gui
    '';
  };
in
{
  dconf.settings = {
    # Reserve Print for Flameshot.
    "org/gnome/shell/keybindings".show-screenshot-ui = [ ];
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screenshot = [ ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "Print";
      command = "${flameshotScreenshot}/bin/flameshot-screenshot";
      name = "flameshot screenshot";
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot".blur = false;
  };

  services.flameshot = {
    enable = true;
    package = flameshot.packages.${pkgs.stdenv.hostPlatform.system}.flameshot;
    settings = {
      General = {
        # Don't pop the "Welcome to Flameshot" message on every restart
        showStartupLaunchMessage = false;
        # Hide the tray icon (Print key is the only entry point)
        disabledTrayIcon = true;
      };
    };
  };
}
