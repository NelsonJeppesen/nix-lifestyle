{ pkgs, ... }: {
  imports = [
    ./chrome.nix
    # ./firefox.nix
    ./flameshot.nix
    ./kitty.nix
    ./slack.nix
    ./tailscale-systray.nix
  ];

  home.packages = [
    # pkgs.mindustry
    pkgs.nerd-fonts.symbols-only # Terminal icons
    pkgs._1password-gui # Password manager
    #pkgs.libreoffice
    # pkgs.onlyoffice-desktopeditors # Office suite (Microsoft-compatible)
    pkgs.spotify # Music streaming
    #pkgs.fractal # Matrix chat client
    #pkgs.google-chrome
    pkgs.zoom-us # Video conferencing
    # pkgs.telegram-desktop
  ];
}
