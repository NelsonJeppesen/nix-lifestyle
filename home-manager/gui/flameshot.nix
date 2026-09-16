{
  pkgs,
  flameshot,
  ...
}:
{
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
