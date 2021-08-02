{ config, pkgs, ... }:
{
  programs = {

    zsh = {
      enable = true;

      history = {
        extended = true;
        save = 999999;
        size = 999999;
      };

      enableCompletion = true;
      enableAutosuggestions = true;

      initExtra = ''
        bindkey -e
        # Single tab complete
        #unsetopt listambiguous
        unsetopt menucomplete

        function set-title-precmd() {
          printf "\e]2;%s\a" "''${PWD/#$HOME/~}"
        }

        function set-title-preexec() {
          printf "\e]2;%s\a" "$1"
        }

        #autoload -Uz add-zsh-hook
        add-zsh-hook precmd set-title-precmd
        add-zsh-hook preexec set-title-preexec

        function powerline_precmd() {
          eval "$(${pkgs.powerline-go}/bin/powerline-go             \
            -path-aliases \~/s=※                                    \
            -colorize-hostname -error $? -shell zsh -eval -newline  \
            -modules kube,newline,cwd,venv,perms,nix-shell,git      \
            -numeric-exit-codes \
          )"
        }

        function install_powerline_precmd() {
          for s in "$\{precmd_functions[@]}"; do
            if [ "$s" = "powerline_precmd" ]; then
              return
            fi
          done
          precmd_functions+=(powerline_precmd)
        }

        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

        if [ "$TERM" != "linux" ]; then
          install_powerline_precmd
          cd ~/s
          clear
        fi
      '';

      sessionVariables = {
        NIXPKGS_ALLOW_UNFREE = "1";
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=4";
        EDITOR = "nvim";
        RPS1 = "";
      };

      shellAliases = {
        update        = "sudo nixos-rebuild switch --upgrade;nix-channel --update; home-manager switch";

        rst           = "kubectx -u; cd ~/s; clear";
        uc            = "kubectx";
        ucu           = "kubectx -u";
        k             = "kubectl";
        kd            = "kubectl describe";
        kg            = "kubectl get";
        kl            = "kubectl logs";
        kgp           = "kubectl get pod";
        ke            = "kubectl edit";
        kns           = "kubens";

        n             = "vim ~/.notes.md";
        v             = "vim";
      };
    };
  };
}
