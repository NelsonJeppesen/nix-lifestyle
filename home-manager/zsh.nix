{ pkgs, ... }:
{
  programs = {
    direnv.enable = true;

    fzf = {
      enable = true;
      defaultOptions = [
        "--layout=reverse"
        # "--color=bw"
      ];
    };

    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];

      settings = {
        filter_mode = "workspace";
        search_node = "fulltext";
        secrets_filter = true;
        show_preview = true;
        sync_address = "http://192.168.5.0:8888";
      };
    };

    starship = {
      enable = true;
      settings = {
        cmd_duration.disabled = true;
        helm.disabled = true;
        python.disabled = true;
        terraform.disabled = true;

        #right_format = "$kubernetes$line_break";
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
        # {
        #   file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        #   name = "zsh-vi-mode";
        #   src = pkgs.zsh-vi-mode;
        # }
      ];

      autosuggestion.enable = true;
      # defaultKeymap = "vicmd";
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      initContent = ''
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

        # ----- Functions migrated from broken alias definitions -----
        ap() {
          local query="$1"
          local profile
          profile="$(${pkgs.awscli2}/bin/aws configure list-profiles | sort | ${pkgs.fzf}/bin/fzf --exact --query="$query" --select-1)"
          if [ -n "$profile" ]; then
            echo export AWS_PROFILE="$profile" > ~/.aws/sticky.profile
            source ~/.aws/sticky.profile
          fi
        }

        ar() {
          local query="$1"
          local region
          region="$(printf '%s\n' us-east-1 ca-central-1 eu-central-1 ap-southeast-2 | ${pkgs.fzf}/bin/fzf --exact --query="$query" --select-1)"
          if [ -n "$region" ]; then
            echo export AWS_REGION="$region" > ~/.aws/sticky.region
            source ~/.aws/sticky.region
          fi
        }

        nsr() {
          if [ -z "$1" ]; then
            echo "usage: nsr <package> [command]" >&2
            return 1
          fi
          local pkg="$1"
          local run_cmd="''${2:-$1}"
          set -x
          nix-shell --packages "$pkg" --run "$run_cmd"
        }

        rgreplace() {
          if [ $# -lt 2 ]; then
            echo "usage: rgreplace <search> <replace>" >&2
            return 1
          fi
            local search="$1"
            local replace="$2"
            rg -l -- "$search" | xargs -r -n1 sed -i "s|$search|$replace|g"
        }
        # ------------------------------------------------------------
      '';

      sessionVariables = {
        DIRENV_LOG_FORMAT = ""; # silence direnv
        MANPAGER = "vim +Man!";
        NIXPKGS_ALLOW_UNFREE = "1";

        # zsh-vi-mode can integrate with your system clipboard
        ZVM_SYSTEM_CLIPBOARD_ENABLED = true;
      };

      shellAliases = {
        # reboot into uefi bios
        reboot-bios = "systemctl reboot --firmware-setup";

        # login via aws sso
        al = "aws sso login";

        # pipe to clipboard
        # Wayland-only clipboard tool
        cbc = "${pkgs.wl-clipboard}/bin/wl-copy";
        cbp = "${pkgs.wl-clipboard}/bin/wl-";

        # short 'n sweet
        g = "${pkgs.git}/bin/git";

        da = "direnv allow";

        # Quick notes
        nw = "nb edit work-$(date +%Y-%m).md      2>/dev/null || nb add --title work-$(date +%Y-%m)";
        np = "nb edit personal-$(date +%Y-%m).md  2>/dev/null || nb add --title personal-$(date +%Y-%m)";
        ns = "$EDITOR $(mktemp)";

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

        # terraform
        t = "${pkgs.terraform}/bin/terraform";
        ta = "${pkgs.terraform}/bin/terraform apply";
        ti = "${pkgs.terraform}/bin/terraform init";
        tp = "${pkgs.terraform}/bin/terraform plan";
        tpv = "${pkgs.terraform}/bin/terraform plan -no-color | vim";
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
