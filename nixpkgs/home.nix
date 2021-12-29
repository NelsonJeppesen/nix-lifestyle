{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./git.nix
    ./gnome-paperwm.nix
    ./kitty.nix
    ./neovim.nix
    ./zsh.nix
  ];

  programs = {
    home-manager.enable = true;
  };

  # Add local scripts
  home.sessionPath = [ "/home/nelson/.local/bin" ];

  services.git-sync.enable = true;
  services.git-sync.repositories.notes.uri = "bogus";
  services.git-sync.repositories.notes.path = "/home/nelson/s/notes";

  news.display = "show";

  home = {

     #file.".config/tuir/tuir.cfg".source = dotfiles/tuir.cfg;
     file.".local/bin".source = ./bin;
     file.".terraform.d/plugin-cache/.empty".source = dotfiles/empty;
     file.".config/run-or-raise/shortcuts.conf".source = dotfiles/shortcuts.conf;
     file.".curlrc".source = dotfiles/curlrc;

     packages = [
      # Browser
      pkgs.google-chrome      # Helpful for --app mode

      # Desktop
      #pkgs.gnomeExtensions.clipboard-indicator  # clipboard manager
      #pkgs.gnomeExtensions.drop-down-terminal
      #pkgs.gnomeExtensions.emoji-selector
      pkgs.flameshot                            # Fancy screenshot tool
      pkgs.gnome3.gpaste
      pkgs.gnomeExtensions.appindicator         # slack notifications
      pkgs.gnomeExtensions.caffeine             # disable sleep on demand
      pkgs.gnomeExtensions.disable-workspace-switch-animation-for-gnome-40
      pkgs.gnomeExtensions.gsconnect
      pkgs.gnomeExtensions.paperwm              # The best tiling window manager
      pkgs.gnomeExtensions.run-or-raise
      pkgs.wmctrl                               # Used to "focus or launch" apps

      # Terminals
      #pkgs.cool-retro-term    # play
      pkgs.kitty              # work
      pkgs.nvimpager

      # DevOps
      pkgs.aws-iam-authenticator
      pkgs.awscli2
      pkgs.curl
      pkgs.dnsutils     # dig
      pkgs.googler
      pkgs.helmfile
      pkgs.jq
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.ripgrep
      pkgs.sops
      pkgs.ssm-session-manager-plugin
      pkgs.terraform
      pkgs.terraform-docs
      pkgs.p7zip
      pkgs.wget
      pkgs.vault

      # Work
      pkgs.zoom-us
      #pkgs.joplin

      # Games
      #pkgs.dosbox     # Simcity 2000
      #pkgs.frotz      # Zork I
      #pkgs.vitetris   # CLI Tetris
      #pkgs.steam

      # Music
      #pkgs.somafm-cli
      #pkgs.ncspot
      pkgs.spotify

      # Reddit
      #pkgs.tuir
    ];
  };
}
