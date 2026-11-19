# Toggle the desktop color preference with a managed keyboard shortcut.
{ pkgs, ... }:
let
  toggleDarkMode = pkgs.writeShellApplication {
    name = "toggle-dark-mode";
    runtimeInputs = [ pkgs.glib ]; # gsettings
    text = ''
      schema=org.gnome.desktop.interface
      if [ "$(gsettings get "$schema" color-scheme)" = "'prefer-dark'" ]; then
        gsettings set "$schema" color-scheme default
      else
        gsettings set "$schema" color-scheme prefer-dark
      fi
    '';
  };
in
{
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/toggle-dark-mode/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/toggle-dark-mode" = {
      binding = "<Shift><Super>d";
      command = "${toggleDarkMode}/bin/toggle-dark-mode";
      name = "toggle dark mode";
    };
  };
}
