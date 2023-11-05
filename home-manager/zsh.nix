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
    zoxide.enable = true;
    direnv.enable = true;

    fzf = {
      enable = true;
      defaultOptions = [ "--layout=reverse" ];
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
        cmd_duration.disabled = true;
        helm.disabled = true;
        python.disabled = true;
        terraform.disabled = true;

        aws = {
          format = "on [$region:$profile $source_profile $duration]($style)";
          region_aliases = {
            ap-southeast-2 = "apse2";
            ca-central-1 = "cac1";
            eu-central-1 = "euc1";
            us-east-1 = "use1";
          };
        };

        kubernetes = {
          # $region:$acount:$cluserName
          context_aliases = { "arn:aws:eks:(?P<aws>.*)cluster/(?P<cluster>.*)" = "$aws$cluster"; };
          disabled = false;
        };
      };
    };

    zsh = {
      enable = true;

      plugins = [{
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
      }];

      defaultKeymap = "emacs";
      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        # alt + [left|right]
        bindkey "^[[1;3C" forward-word
        bindkey "^[[1;3D" backward-word

        # kitty tab title to $PWD
        function set-title-precmd() {printf "\e]2;%s\a" "''${PWD/*\//}"}
        add-zsh-hook precmd set-title-precmd

        # kitty tab title to running command
        function set-title-preexec() {printf "\e]2;%s\a" "$1"}
        add-zsh-hook preexec set-title-preexec

        # If opening a new terminal, switch to repo dir
        if [[ "$TERM" != "linux" && "$(pwd)" = "$HOME" ]]; then
          cd ~/Documents
          clear
        fi
      '';

      sessionVariables = {
        DIRENV_LOG_FORMAT = ""; # silence direnv
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
        NIXPKGS_ALLOW_UNFREE = "1";
      };

      shellAliases = {
        # reboot into uefi bios
        reboot-bios = "systemctl reboot --firmware-setup";

        # fuzzy find aws profile
        ap = ''(){echo export AWS_PROFILE="$(${pkgs.awscli2}/bin/aws configure list-profiles|${pkgs.fzf}/bin/fzf --exact --query=$1 --select-1)" > ~/.aws/sticky.profile;source ~/.aws/sticky.profile}'';

        # fuzzy find aws region
        ar = ''(){echo export AWS_REGION="$(echo 'us-east-1\nca-central-1\neu-central-1\nap-southeast-2'|${pkgs.fzf}/bin/fzf --exact --query=$1 --select-1)" > ~/.aws/sticky.region;source ~/.aws/sticky.region}'';

        # login via aws sso
        al = "aws sso login";

        clipboard = "${pkgs.xsel}/bin/xsel --clipboard";

        # Chat GPT chatbot
        cb = "chatblade";
        cb3 = "chatblade -c 4";
        cb4 = "chatblade -c 3.5";

        # short 'n sweet
        g = "${pkgs.git}/bin/git";
        h = "${pkgs.helmfile}/bin/helmfile";

        # Quick notes
        n = "nb edit work-$(date +%Y-%q)     2>/dev/null || nb add --title work-$(date +%Y-%q)";
        np = "nb edit personal-$(date +%Y-%q) 2>/dev/null || nb add --title personal-$(date +%Y-%q)";

        ls = "ls --almost-all --group-directories-first --color=auto";
        l = "ls --almost-all --group-directories-first --color=auto -1";

        # reset
        rst = ''
          cd ~/Documents
          kubectx --unset
          echo > ~/.aws/sticky.profile
          echo > ~/.aws/sticky.region
          unset AWS_PROFILE
          unset AWS_REGION
          clear
        '';

        # calculator
        f = "fend";
        fc = "clear;fend";

        w = "walk";

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
        ucu = "kubectx --unset";
      };
    };
  };
}
