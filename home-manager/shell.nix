{ config, pkgs, ... }:
{
  programs = {

    direnv.enable = true; # load .envrc files
    fzf.enable = true; # fuzzy finder
    mcfly.enable = true; # sqlite based shell history

    taskwarrior = {
      enable = true;
      dataLocation = "$HOME/s/notes/taskwarrior";
      config = {
        uda.taskwarrior-tui.task-report.show-info = false;
        uda.taskwarrior-tui.task-report.next.filter = "(status:pending or status:waiting)";
      };
    };

    starship = {
      enable = true;
      settings = {
        # Disabled
        aws.disabled = true;
        helm.disabled = true;
        terraform.disabled = true;

        # Enabled
        kubernetes.disabled = false;

        custom.taskwarrior_pending = {
          command = "${pkgs.taskwarrior}/bin/task count rc.gc=off rc.verbose=nothing status:pending";
          description = "Count of pending Taskwarrior tasks";
          symbol = "⇞";
          style = "blue";
          when = "which task";
        };

        custom.taskwarrior_complete_today = {
          command = "${pkgs.taskwarrior}/bin/task count rc.gc=off rc.verbose=nothing status:completed end.after:yesterday";
          description = "Count of pending Taskwarrior tasks";
          symbol = "";
          when = "which task";
        };

      };
    };

    zsh = {
      enable = true;

      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;

      initExtraFirst = ''
        # Setup emacs keybindings before fzf bindings are added
        bindkey -e
      '';

      initExtra = ''
        # Set Kitty Terminal title of PWD
        function set-title-precmd() {
          printf "\e]2;%s\a" "''${PWD/#$HOME/~}"
        }

        # Set Kitty Terminal title to the running command
        function set-title-preexec() {
          printf "\e]2;%s\a" "$1"
        }

        # Use menu for autocomplete
        # https://stackoverflow.com/questions/13613698/zsh-history-completion-menu
        zstyle ':completion:*' menu yes select

        # https://superuser.com/questions/160750/can-zsh-do-2-stage-completion
        zstyle ':completion:*' menu select=1
        zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

        #autoload -Uz add-zsh-hook
        add-zsh-hook precmd set-title-precmd
        add-zsh-hook preexec set-title-preexec

        # If opening a new terminal, switch to ~s and clear the screen
        if [ "$TERM" != "linux" ]; then
          if [ "$(pwd)" = "$HOME" ]; then
            cd ~/s
            clear
          fi
        fi
      '';

      sessionVariables = {
        # Install non-free packages e.g. Steam
        NIXPKGS_ALLOW_UNFREE = "1";
        FZF_DEFAULT_OPTS = "--layout=reverse";
        # Autosuggest as orange
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=3";
        MCFLY_FUZZY = "true";
        MCFLY_RESULTS = "20";
        # Use NeoVim is my editor for all
        EDITOR = "nvim";
        # Use NemVim as my pager; enable copy into clipboard
        PAGER = "nvimpager -- --cmd 'set clipboard^=unnamed,unnamedplus'";
      };

      shellAliases = {
        mynix = ''vim $(find ~/s/play/nix-lifestyle|grep  '.nix$'|fzf)'';
        weather = "${pkgs.curl}/bin/curl wttr.in/\\?format=4";

        # short 'n sweet
        g = "${pkgs.git}/bin/git";
        h = "${pkgs.helmfile}/bin/helmfile";
        n = "${pkgs.neovim}/bin/nvim ~/s/notes/$(date +work-%Y-%q).md";
        s = "${pkgs.neovim}/bin/nvim ~/s/notes/scratch.md";

        # retrain my old mind; either to short name or better cli tools from gnu
        git = "bad";
        helmfile = "bad";
        find = "bad";

        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # Enable aliases from within `watch`
        watch = "watch ";

        # reset terminal
        rst = "cd ~/s; clear";

        # fend calculator
        f = "fend";
        ff = "clear;fend";

        # taskwarrior and taskwarrior-tui
        twa = "${pkgs.taskwarrior}/bin/task add";
        tw = "${pkgs.taskwarrior-tui}/bin/taskwarrior-tui";

        # terraform
        t = "${pkgs.terraform}/bin/terraform";
        ta = "${pkgs.terraform}/bin/terraform apply";
        ti = "${pkgs.terraform}/bin/terraform init";
        tp = "${pkgs.terraform}/bin/terraform plan";
        tsd = "echo $(${pkgs.terraform}/bin/terraform state list|fzf --multi)|xargs -n1 ${pkgs.terraform}/bin/terraform state rm";
        tss = "${pkgs.terraform}/bin/terraform state show $(${pkgs.terraform}/bin/terraform state list|fzf)";
        tt = "echo $(${pkgs.terraform}/bin/terraform state list|fzf --multi)|xargs -n1 ${pkgs.terraform}/bin/terraform taint";
        terraform = "bad";

        # use fuzzy finder to connect to one more more vpns quickly
        vpn = "nmcli con|grep vpn|grep -- --|choose 0|fzf --multi|xargs --max-procs 9 -L1 nmcli con up id";

        # kube
        uc = "kubectx";
        k = "kubectl";
        kns = "kubens";
        kg = "kubectl get";
        kgs = ''kubectl get --no-headers -o custom-columns=":metadata.name"'';
        kdp = "k delete pod $(kgs pod|fzf --multi)";

        # interactive ripgrep
        irg = ''INITIAL_QUERY=""
          RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case " \
          FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'"     \
          fzf -m --bind "change:reload:$RG_PREFIX {q} || true"  \
              --ansi --disabled --query "$INITIAL_QUERY"        \
              --height=50% --layout=reverse'';
      };
    };
  };
}
