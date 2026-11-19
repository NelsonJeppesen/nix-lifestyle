# Own screenshot shortcuts and launch Flameshot with a fresh capture process.
{
  config,
  pkgs,
  ...
}:
let
  flameshotScreenshot = pkgs.writeShellApplication {
    name = "flameshot-screenshot";
    runtimeInputs = [
      pkgs.procps
      pkgs.coreutils
    ];
    text = ''
      # Replace only this user's capture process. A stuck process must not
      # leave a keyboard-shortcut launcher polling forever.
      pkill -u "$UID" -f '/bin/[f]lameshot( |$)' || true
      attempts=0
      while pgrep -u "$UID" -f '/bin/[f]lameshot( |$)' >/dev/null; do
        if (( attempts >= 100 )); then
          printf 'flameshot-screenshot: capture process did not exit within five seconds\n' >&2
          exit 1
        fi
        attempts=$((attempts + 1))
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
      command = ''${flameshotScreenshot}/bin/flameshot-screenshot gui --region all --clipboard --path "${config.xdg.userDirs.pictures}"'';
      name = "flameshot full-screen screenshot";
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot".blur = false;
  };

  services.flameshot = {
    enable = true;
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
