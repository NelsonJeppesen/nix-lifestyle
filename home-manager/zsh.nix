{ config, pkgs, ... }:
{
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        max_line_width = 0;
        indent_style = "space";
        indent_size = 2;
      };
    };
  };

  programs = {
    broot.enable = true;
    direnv.enable = true;

    fzf = {
      enable = true;
      defaultOptions = [
        "--color=bw"
        "--layout=reverse"
      ];
    };

    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = false;
        inline_height = 13;
        search_node = "fulltext";
        style = "full";
      };
    };

    starship = {
      enable = true;
      settings = {
        aws.format = "on [$profile $source_profile $duration]($style)";

        cmd_duration.disabled = true;
        helm.disabled = true;
        terraform.disabled = true;

        kubernetes = {
          disabled = false;
          context_aliases = { "arn.*:cluster/(?P<cluster>.*)" = "$cluster"; }; # keep only eks suffix
        };
      };
    };

    zsh = {
      enable = true;

      plugins = [
        {
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
        }
      ];

      defaultKeymap = "emacs";
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;

      initExtra = ''
        # unset broken trash zsh comp
        unset '_comps[trash]'

        # alt + [left|right]
        bindkey "^[[1;3C" forward-word
        bindkey "^[[1;3D" backward-word

        # kitty tab title to $PWD
        function set-title-precmd() {   printf "\e]2;%s\a" "''${PWD/*\//}"}
        add-zsh-hook precmd set-title-precmd

        # kitty tab title to running command
        function set-title-preexec() {printf "\e]2;%s\a" "$1"}
        add-zsh-hook preexec set-title-preexec

        # If opening a new terminal, switch to ~s and clear the screen
        if [ "$TERM" != "linux" ]; then
          if [ "$(pwd)" = "$HOME" ]; then
            cd ~/s; clear
          fi
        fi
      '';

      sessionVariables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        NIXPKGS_ALLOW_UNFREE = "1";
      };

      shellAliases = {
        # reboot into uefi bios
        reboot-bios = "systemctl reboot --firmware-setup";

        # aws cli
        ap = ''(){echo export AWS_PROFILE="$(${pkgs.awscli2}/bin/aws configure list-profiles|${pkgs.fzf}/bin/fzf --query=$1 --select-1)" > ~/.aws/sticky.profile;source ~/.aws/sticky.profile}'';
        al = "aws sso login";

        cb = "${pkgs.xsel}/bin/xsel --clipboard";

        # short 'n sweet
        g = "${pkgs.git}/bin/git";
        h = "${pkgs.helmfile}/bin/helmfile";
        j = "${pkgs.joplin}/bin/joplin";
        #n = "${pkgs.neovim}/bin/nvim ~/s/notes/$(date +work-%Y-%q).md";
        #s = "${pkgs.neovim}/bin/nvim ~/s/notes/scratch.md";

        ls = "ls --almost-all --group-directories-first --color=auto";
        l = "ls --almost-all --group-directories-first --color=auto -1";

        # reset
        rst = "cd ~/s;kubectx --unset; echo > ~/.aws/sticky.profile;unset AWS_PROFILE; clear";

        # calculator
        f = "fend";
        fc = "clear;fend";

        random-theme = ''precmd() {a=$(find /nix/store/3a0j7pdbj8hi0lzfmahxqp37rq3d6swp-kitty-themes-unstable-2023-03-08/share/kitty-themes/themes/*.conf | sort -R |head -n1);kitty @ set-colors --all $a;basename $a}'';

        # terraform
        t = "${pkgs.terraform}/bin/terraform";
        ta = "${pkgs.terraform}/bin/terraform apply";
        ti = "${pkgs.terraform}/bin/terraform init";
        tp = "${pkgs.terraform}/bin/terraform plan";
        tsd = "echo $(${pkgs.terraform}/bin/terraform state list|fzf --multi)|xargs -n1 ${pkgs.terraform}/bin/terraform state rm";
        tss = "${pkgs.terraform}/bin/terraform state show $(${pkgs.terraform}/bin/terraform state list|fzf)";
        tt = "echo $(${pkgs.terraform}/bin/terraform state list|fzf --multi)|xargs -n1 ${pkgs.terraform}/bin/terraform taint";

        # kube
        k = "kubectl";
        kns = "kubens";
        uc = "kubectx";
      };
    };
  };
}
