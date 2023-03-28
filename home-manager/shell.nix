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

    direnv.enable = true; # load .envrc files
    fzf.enable = true; # fuzzy finder
    #mcfly.enable = true; # sqlite based shell history
    atuin.enable = true;
    atuin.settings = {
      auto_sync = false;
      style = "compact";
      search_node = "fuzzy";
    };

    taskwarrior = {
      colorTheme = "dark-violets-256";
      dataLocation = "$HOME/s/notes/taskwarrior";
      enable = true;
      config = {
        report.personal.filter = "project:personal stats:pending";
        report.work.filter = "project:work status:pending";
        uda.taskwarrior-tui.task-report.looping = false;
        uda.taskwarrior-tui.task-report.next.filter = "(status:pending or status:waiting)";
        uda.taskwarrior-tui.task-report.show-info = false;
      };
    };

    starship = {
      enable = true;
      settings = {

        # Disabled
        helm.disabled = true;
        terraform.disabled = true;

        # Enabled
        kubernetes.disabled = false;

        #custom.taskwarrior_pending_work = {
        #  command = "${pkgs.taskwarrior}/bin/task count rc.gc=off rc.verbose=nothing status:pending project:work";
        #  description = "Count of pending Taskwarrior tasks";
        #  symbol = "⇞";
        #  style = "blue";
        #  when = "which task";
        #};

        #custom.taskwarrior_pending_personal = {
        #  command = "${pkgs.taskwarrior}/bin/task count rc.gc=off rc.verbose=nothing status:pending project:personal";
        #  description = "Count of pending Taskwarrior tasks";
        #  symbol = "⨃";
        #  style = "blue";
        #  when = "which task";
        #};

        #custom.taskwarrior_complete_today = {
        #  command = "${pkgs.taskwarrior}/bin/task count rc.gc=off rc.verbose=nothing status:completed end.after:yesterday";
        #  description = "Count of pending Taskwarrior tasks";
        #  symbol = "";
        #  when = "which task";
        #};

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

      profileExtra = ''
        # revert to default uparrow instead of atuin
      '';

      loginExtra = ''
        bindkey "^[OA" up-line-or-history
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
        bindkey "^[OA" up-line-or-history
      '';

      sessionVariables = {
        # use vim-manpager vim plugin in nvim for man pages
        MANPAGER = "nvim +Man!";

        # Install non-free packages e.g. Steam
        NIXPKGS_ALLOW_UNFREE = "1";
        FZF_DEFAULT_OPTS = "--layout=reverse";

        # Autosuggest as orange
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=3";
        MCFLY_FUZZY = "true";
        MCFLY_DISABLE_MENU = "true";
        MCFLY_RESULTS = "20"; # default: 10
        MCFLY_RESULTS_SORT = "LAST_RUN";

        # Use NeoVim is my editor for all
        EDITOR = "nvim";

        # Use NemVim as my pager; enable copy into clipboard
        #PAGER = "nvimpager -- --cmd 'set clipboard^=unnamed,unnamedplus'";
      };

      shellAliases = {
        mynix = ''vim $(find ~/s/play/nix-lifestyle|grep  '.nix$'|fzf)'';
        weather = "${pkgs.curl}/bin/curl wttr.in/\\?format=4";
        bios = "systemctl reboot --firmware-setup";

        ap = ''export AWS_PROFILE="$(${pkgs.awscli2}/bin/aws configure list-profiles|${pkgs.fzf}/bin/fzf)"'';
        al = "aws sso login";


        cb = "${pkgs.xsel}/bin/xsel --clipboard";

        c = "curl";
        ch = "curl  -X get --head";
        chv = "curl -X get --head --verbose";
        cs = "curl --silent";
        cv = "curl --verbose";

        # short 'n sweet
        g = "${pkgs.git}/bin/git";
        h = "${pkgs.helmfile}/bin/helmfile";
        n = "nvim ~/s/notes/$(date +work-%Y-%q).md";
        s = "nvim ~/s/notes/scratch.md";

        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # Enable aliases from within `watch`
        watch = "${pkgs.viddy}/bin/viddy";

        # reset terminal
        rst = "cd ~/s;
        clear";

        # fend calculator
        f = "fend";
        ff = "clear;fend";

        # taskwarrior and taskwarrior-tui
        twaw = "${pkgs.taskwarrior}/bin/task add project:work";
        twap = "${pkgs.taskwarrior}/bin/task add project:personal";
        twc = "${pkgs.taskwarrior}/bin/task completed end.after:today-8days";
        tw = "${pkgs.taskwarrior-tui}/bin/taskwarrior-tui";

        # terraform
        t = "${pkgs.terraform}/bin/terraform";
        ta = "${pkgs.terraform}/bin/terraform apply";
        ti = "${pkgs.terraform}/bin/terraform init";
        tp = "${pkgs.terraform}/bin/terraform plan";
        tsd = "echo $(${pkgs.terraform}/bin/terraform state list|fzf --multi)|xargs -n1 ${pkgs.terraform}/bin/terraform state rm";
        tss = "${pkgs.terraform}/bin/terraform state show $(${pkgs.terraform}/bin/terraform state list|fzf)";
        tt = "echo $(${pkgs.terraform}/bin/terraform state list|fzf --multi)|xargs -n1 ${pkgs.terraform}/bin/terraform taint";

        # kube
        uc = "kubectx";
        k = "kubectl";
        kns = "kubens";
        kg = "kubectl get";
        kgs = ''kubectl get --no-headers -o custom-columns=":metadata.name"'';
        kdp = "k delete pod $(kgs pod|fzf --multi)";

        # interactive ripgrep
        irg = ''INITIAL_QUERY=""
          RG_PREFIX="rg --column --line-number --no-heading --color = always - -smart-case " \
          FZF_DEFAULT_COMMAND="$
          RG_PREFIX '$
          INITIAL_QUERY' "     \
          fzf -m --bind " change:reload:$RG_PREFIX { q } || true"  \
              --ansi --disabled --query "$INITIAL_QUERY"        \
              --height=50% --layout=reverse'';
      };
    };
  };
}
