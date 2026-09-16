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
      exec ${config.services.flameshot.package}/bin/flameshot "$@"
    '';
  };
in
{
  dconf.settings = {
    # Reserve Print and Shift+Print for Flameshot.
    "org/gnome/shell/keybindings" = {
      show-screenshot-ui = [ ];
      screenshot = [ ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      screenshot = [ ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot-full/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "Print";
      command = "${flameshotScreenshot}/bin/flameshot-screenshot gui";
      name = "flameshot screenshot";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/flameshot-full" = {
      binding = "<Shift>Print";
      command = ''${flameshotScreenshot}/bin/flameshot-screenshot full --clipboard --path "${config.xdg.userDirs.pictures}"'';
      name = "flameshot full-screen screenshot";
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
        # Use keyboard shortcuts instead of the tray.
        disabledTrayIcon = true;
      };
    };
  };
}
