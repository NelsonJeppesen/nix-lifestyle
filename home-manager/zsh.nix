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
    fzf.enable = true;

    atuin.settings = {
      enable = true;
      auto_sync = false;
      style = "compact";
      search_node = "fuzzy";
    };

    starship = {
      enable = true;
      settings = {
        aws.format = "on [$profile $duration]($style)";
        cmd_duration.disabled = true;
        helm.disabled = true;
        kubernetes.disabled = false;
        terraform.disabled = true;
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
        MANPAGER = "nvim +Man!";
        NIXPKGS_ALLOW_UNFREE = "1";
        FZF_DEFAULT_OPTS = "--layout=reverse";
        EDITOR = "nvim";
      };

      shellAliases = {
        # reboot into uefi bios
        reboot-bios = "systemctl reboot --firmware-setup";

        # aws cli
        ap = ''(){export AWS_PROFILE="$(${pkgs.awscli2}/bin/aws configure list-profiles|${pkgs.fzf}/bin/fzf --query=$1 --select-1)";}'';
        al = "aws sso login";

        cb = "${pkgs.xsel}/bin/xsel --clipboard";

        # short 'n sweet
        g = "${pkgs.git}/bin/git";
        h = "${pkgs.helmfile}/bin/helmfile";
        n = "${pkgs.neovim}/bin/nvim ~/s/notes/$(date +work-%Y-%q).md";
        s = "${pkgs.neovim}/bin/nvim ~/s/notes/scratch.md";

        # reset
        rst = "cd ~/s; clear";

        # calculator
        f = "fend";
        fc = "clear;fend";

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
