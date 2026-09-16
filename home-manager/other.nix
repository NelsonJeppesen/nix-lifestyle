{ config, ... }: {
  nixpkgs.config.allowUnfree = true;
  # User directories.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    download = "${config.home.homeDirectory}/Downloads";
    # documents = "${config.home.homeDirectory}/Documents";
    # music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    # videos = "${config.home.homeDirectory}/Videos";
    # publicShare = "${config.home.homeDirectory}/Public";
    # templates = "${config.home.homeDirectory}/Templates";
    # desktop = "${config.home.homeDirectory}/Desktop";
  };

  # Home Manager CLI.
  programs.home-manager.enable = true;
  # User fonts.
  fonts.fontconfig.enable = true;

  # Encrypted secrets.
  age.secrets = {
    # direnv .envrc for personal projects (API keys, tokens, etc.)
    "envrc_personal" = {
      file = "/etc/secrets/encrypted/envrc.personal.age";
      path = "${config.home.homeDirectory}/source/personal/.envrc";
    };

    # AWS credentials for personal account
    "awscredentials.personal" = {
      file = "/etc/secrets/encrypted/awscredentials.personal.age";
      path = "${config.home.homeDirectory}/source/personal/.aws/credentials";
    };

    # Writable kubeconfig source.
    "kubeconfig.personal" = {
      file = "/etc/secrets/encrypted/kubeconfig.personal.age";
      path = "${config.home.homeDirectory}/source/personal/.kube/config.orig";
    };

    # direnv .envrc for the root source directory
    "envrc_root" = {
      file = "/etc/secrets/encrypted/envrc.root.age";
      path = "${config.home.homeDirectory}/source/.envrc";
    };

  };

  home = {
    # State compatibility; change only for migrations.
    stateVersion = "26.05";
    username = "nelson";
    homeDirectory = "/home/nelson";

  };
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        max_line_length = "off"; # disable line-length checks
        indent_style = "space";
        indent_size = 2;
      };
    };
  };
}
