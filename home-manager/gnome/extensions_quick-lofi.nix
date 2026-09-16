{ pkgs, ... }: {
  dconf.settings = {
    "org/gnome/shell/extensions/quick-lofi" = {
      volume = 75;
      set-popup-max-height = false;
      enable-mini-player = false;
      enable-mpris = false;

      indicator-actions = [
        "showPopupMenu"
        "playPause"
        "stopPlayer"
      ];

      radios = [
        "SomaFM Ambient Dark Zone - https://api.somafm.com/darkzone130.pls"
        "SomaFM Ambient Deep Space One - https://api.somafm.com/deepspaceone130.pls"
        "SomaFM Ambient Doomed - https://api.somafm.com/doomed130.pls"
        "SomaFM Ambient Drone Zone - https://api.somafm.com/dronezone130.pls"
        "SomaFM Ambient Drone Zone 2 - https://api.somafm.com/dz2130.pls"
        "SomaFM Ambient Groove Salad - https://api.somafm.com/groovesalad130.pls"
        "SomaFM Ambient Groove Salad 2 - https://api.somafm.com/groovesalad2130.pls"
        "SomaFM Ambient Groove Salad Classic - https://api.somafm.com/gsclassic130.pls"
        "SomaFM Ambient Mission Control - https://api.somafm.com/missioncontrol130.pls"
        "SomaFM Ambient SF 10-33 - https://api.somafm.com/sf1033130.pls"
        "SomaFM Ambient Synphaera Radio - https://api.somafm.com/synphaera130.pls"

        "SomaFM Americana Boot Liquor - https://api.somafm.com/bootliquor130.pls"

        "SomaFM Electronic Beat Blender - https://api.somafm.com/beatblender130.pls"
        "SomaFM Electronic cliqhop idm - https://api.somafm.com/cliqhop130.pls"
        "SomaFM Electronic DEF CON Radio - https://api.somafm.com/defcon130.pls"
        "SomaFM Electronic Digitalis - https://api.somafm.com/digitalis130.pls"
        "SomaFM Electronic Dub Step Beyond - https://api.somafm.com/dubstep130.pls"
        "SomaFM Electronic Fluid - https://api.somafm.com/fluid130.pls"
        "SomaFM Electronic Lush - https://api.somafm.com/lush130.pls"
        "SomaFM Electronic Space Station Soma - https://api.somafm.com/spacestation130.pls"
        "SomaFM Electronic The Trip - https://api.somafm.com/thetrip130.pls"
        "SomaFM Electronic Underground 80s - https://api.somafm.com/u80s130.pls"
        "SomaFM Electronic Vaporwaves - https://api.somafm.com/vaporwaves130.pls"

        "SomaFM Spoken SF in SF - https://api.somafm.com/sfinsf130.pls"
      ];
    };
  };

  programs.gnome-shell.extensions = [
    {
      package = pkgs.gnomeExtensions.quick-lofi;
    }
  ];

  home.packages = [
    pkgs.socat # mpv IPC
    (pkgs.mpv.override { youtubeSupport = false; }) # Radio playback
    # pkgs.cava # Audio visualizer
  ];
}
