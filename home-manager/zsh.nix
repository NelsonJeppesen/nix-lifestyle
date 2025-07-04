{  pkgs, ... }:
{
  programs = {
    direnv.enable = true;

    fzf = {
      enable = true;
      defaultOptions = [
        "--layout=reverse"
        "--color=bw"
      ];
    };

    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];

      settings = {
        sync_address = "http://192.168.5.0:8888";
        inline_height = 999;
        search_node = "fulltext";
        secrets_filter = true;
        show_preview = true;

        #style = "full";
      };
    };

    starship = {
      enable = true;
      settings = {
        cmd_duration.disabled = true;
        helm.disabled = true;
        python.disabled = true;
        terraform.disabled = true;

        #right_format = "$kubernetes$line_break\";
        fill = {
          symbol = " ";
        };

        format =
          # move kubernetes to the right
          "$all$fill$kubernetes$line_break$directory$git_branch$git_status$jobs$battery$time$status$os$container$shell$character";

        directory = {
          truncation_length = 9;
          repo_root_style = "bright-yellow";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style))\\] ";
          #up_to_date = "[✓](green)";
          #stashed = "[\\$\\($count\\)](green)";
          #deleted = "[--\\($count\\)](red)";
        };

        git_branch = {
          format = "\\[[$branch(:$remote_branch)]($style) ";
        };

        aws = {
          format = "\\[[$profile]($style) $region\\]";
          region_aliases = {
            ap-southeast-2 = "apse2";
            ca-central-1 = "cac1";
            eu-central-1 = "euc1";
            us-east-1 = "use1";
            us-east-2 = "use2";
            us-west-1 = "usw1";
            us-west-2 = "usw2";
          };
        };

        kubernetes = {
          disabled = false;
          format = "\\[$namespace [$context]($style)\\]";
          contexts = [
            {
              context_pattern = "arn:aws:eks:(?P<aws>.*)cluster/(?P<cluster>.*)";
              context_alias = "$aws$cluster";
            }
          ];
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

      autosuggestion.enable = true;
      defaultKeymap = "emacs";
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      initContent = ''
        # ctrl+[left|right] word
        bindkey "^[[1;5C" forward-word
        bindkey "^[[1;5D" backward-word

        # kitty tab title to $PWD
        function set-title-precmd() {printf "\e]2;%s\a" "''${PWD/*\//}"}
        add-zsh-hook precmd set-title-precmd

        # kitty tab title to running command
        function set-title-preexec() {printf "\e]2;%s\a" "$1"}
        add-zsh-hook preexec set-title-preexec

        # If opening a new terminal, not over SSH, cd to code directory and clear screen
        if [[ "$TERM" != "linux" && "$(pwd)" = "$HOME" && ! "$SSH_CLIENT" ]]; then
          cd ~/source
          clear
        fi
      '';

      sessionVariables = {
        DIRENV_LOG_FORMAT = ""; # silence direnv
        MANPAGER = "vim +Man!";
        NIXPKGS_ALLOW_UNFREE = "1";
      };

      shellAliases = {
        # reboot into uefi bios
        reboot-bios = "systemctl reboot --firmware-setup";

        # fuzzy find aws profile
        apu = "unset AWS_PROFILE";
        ap = ''(){echo export AWS_PROFILE="$(${pkgs.awscli2}/bin/aws configure list-profiles|sort|${pkgs.fzf}/bin/fzf --exact --query=$1 --select-1)" > ~/.aws/sticky.profile;source ~/.aws/sticky.profile}'';

        # fuzzy find aws region
        ar = ''(){echo export AWS_REGION="$(echo 'us-east-1\nca-central-1\neu-central-1\nap-southeast-2'|${pkgs.fzf}/bin/fzf --exact --query=$1 --select-1)" > ~/.aws/sticky.region;source ~/.aws/sticky.region}'';

        # login via aws sso
        al = "aws sso login";

        a = "sgpt";

        # pipe to clipboard
        clipboard = "${pkgs.xsel}/bin/xsel --clipboard";

        # short 'n sweet
        g = "${pkgs.git}/bin/git";
        h = "${pkgs.helmfile}/bin/helmfile";

        da = "direnv allow";

        # Quick notes
        n = "nb edit work-$(date +%Y-%m).md      2>/dev/null || nb add --title work-$(date +%Y-%m)";
        np = "nb edit personal-$(date +%Y-%m).md 2>/dev/null || nb add --title personal-$(date +%Y-%m)";

        nsr = ''nsrfun() {if [ "$2" = "" ];then 2="$1";fi;set -x;nix-shell --packages $1 --run $2};nsrfun'';

        # reset
        rst = ''
          cd ~/source
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

        jci = "jira issue create --assignee 'Nelson Jeppesen' --label SRETasks";
        jil = "jira issue list   --assignee 'Nelson Jeppesen' --updated '-2w' --order-by RESOLUTION";
        jdone = ''jira issue list --assignee 'Nelson Jeppesen' --updated '-2w' --order-by 'RESOLUTION' --jql 'resolution = EMPTY' --plain --columns KEY,SUMMARY --no-headers | fzf --select-1 --bind 'enter:execute(jira issue move {1} "Resolve Issue" --resolution Done)+abort' '';

        check-ptr = ''
          (){
                        FORWARD_IP="$(dig $1 +short)"
                        PTR_HOSTNAME="$(dig -x $FORWARD_IP +short)"
                        if [ "$1." = "$PTR_HOSTNAME" ];then MATCH="✅";else MATCH="❌";fi
                        echo -e "$MATCH $1 --> ''${FORWARD_IP:=missing}\n   ''${FORWARD_IP:=missing} --> ''${PTR_HOSTNAME:=missing}"
                      }
        '';

        # terraform
        t = "${pkgs.terraform}/bin/terraform";
        ta = "${pkgs.terraform}/bin/terraform apply";

        ti = "${pkgs.terraform}/bin/terraform init";

        tp = "${pkgs.terraform}/bin/terraform plan";

        # pipe plan into vim
        tpv = "${pkgs.terraform}/bin/terraform plan -no-color | vim";

        # pipe plan into vim, just listing the objects to change
        tpwb = "${pkgs.terraform}/bin/terraform plan -no-color | grep '#.*will be' | vim";

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
