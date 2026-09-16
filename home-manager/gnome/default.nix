{ pkgs, ... }: {
  imports = [
    ./gnome.nix
    ./gnome-extensions.nix
  ];

  home.packages = [
    pkgs.socat # mpv IPC
    (pkgs.mpv.override { youtubeSupport = false; }) # Media player (backend for Quick Lofi)
    # pkgs.cava # Console audio visualizer
  ];
}
