{ config, lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./git.nix
    ./gnome.nix
    ./gnome-extensions.nix
    ./kitty.nix
    ./neovim.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  # Add local scripts
  home.sessionPath = [ "/home/nelson/.local/bin" ];

  programs.firefox = {
    enable = true;
    profiles = {
      home = {
        id = 0;
        name = "home";
        userChrome = "
          #TabsToolbar
          { visibility: collapse; }
        ";
        settings = {
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "layout.css.backdrop-filter.enabled" = true;
          "svg.context-properties.content.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
    };
  };

  home = {
    stateVersion = "22.05";
    username = "nelson";
    homeDirectory = "/home/nelson";

    file.".local/bin".source = ./bin;
    file.".terraform.d/plugin-cache/.empty".source = ./dotfiles/empty;
    file.".config/fend/config.toml".source = ./dotfiles/fend.toml;

    packages = [
      pkgs.flameshot

      # notes
      pkgs.joplin
      pkgs.joplin-desktop

      # nixpkgs maintainer
      pkgs.nixpkgs-review

      # fun
      pkgs.mindustry
      pkgs.vitetris

      # formaters
      pkgs.shfmt
      pkgs.nixpkgs-fmt

      # chill
      #pkgs.somafm-cli forked
      pkgs.spotify

      # core GUI apps
      #pkgs.fractal
      #pkgs.google-chrome
      pkgs.kitty
      pkgs.slack
      pkgs.zoom-us

      # cloud management
      pkgs.awscli2
      pkgs.ssm-session-manager-plugin
      pkgs.terraform

      # better shell scripts
      pkgs.shellcheck
      pkgs.shfmt

      # core shell tools
      pkgs.btop
      pkgs.choose
      pkgs.curl
      pkgs.dnsutils
      pkgs.entr
      pkgs.fd
      pkgs.fend
      pkgs.gomplate
      pkgs.ipcalc
      pkgs.jq
      pkgs.p7zip
      pkgs.ripgrep
      pkgs.vault
      pkgs.wget
      pkgs.wl-clipboard

      # Kubernetes
      pkgs.glooctl
      pkgs.helmfile
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.sops
      pkgs.stern
      pkgs.velero
    ];
  };
}
