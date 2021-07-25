{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./programs/git.nix
    ./programs/gnome-paperwm.nix
    ./programs/kitty.nix
    ./programs/neovim.nix
    ./programs/shell.nix
  ];

  programs = {
    home-manager.enable = true;
  };

  news.display = "show";

  home = {

     #file.".config/tuir/tuir.cfg".source = dotfiles/tuir.cfg;

     packages = [
      # Browser
      pkgs.google-chrome      # Helpful for --app mode

      # Desktop
      pkgs.gnomeExtensions.paperwm              # The best tiling window manager
                                                # and the reason I use Linux full-time

      pkgs.flameshot                            # Fancy screenshot tool
      pkgs.gnomeExtensions.appindicator         # slack notifications
      pkgs.gnomeExtensions.caffeine             # disable sleep on demand
      #pkgs.gnomeExtensions.clipboard-indicator  # clipboard manager
      pkgs.gnome3.gpaste
      pkgs.gnomeExtensions.gsconnect
      #pkgs.gnomeExtensions.drop-down-terminal
      pkgs.gnomeExtensions.emoji-selector
      pkgs.wmctrl                               # Used to "focus or launch" apps

      # Terminals
      pkgs.cool-retro-term    # play
      pkgs.kitty              # work

      # DevOps
      pkgs.aws-iam-authenticator
      pkgs.awscli2
      pkgs.curl
      pkgs.direnv
      #pkgs.dbeaver      # multi-db gui
      pkgs.dnsutils     # dig
      pkgs.helmfile
      pkgs.jq
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.ripgrep
      pkgs.sops
      pkgs.ssm-session-manager-plugin
      pkgs.terraform_0_15
      pkgs.terraform-docs
      pkgs.p7zip
      pkgs.wget

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
