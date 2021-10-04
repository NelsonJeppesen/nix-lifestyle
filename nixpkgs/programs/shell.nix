{ config, pkgs, ... }:
{
  programs = {

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # Disabled
        aws.disabled        = true;
        helm.disabled       = true;
        terraform.disabled  = true;

        # Enabled
        kubernetes.disabled = false;
      };
    };

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

        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
        bindkey -v

        if [ "$TERM" != "linux" ]; then
          if [ "$(pwd)" = "$HOME" ]; then
            cd ~/s
            clear
          fi
        fi
      '';

      sessionVariables = {
        NIXPKGS_ALLOW_UNFREE = "1";
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=4";
        EDITOR = "nvim";
        RPS1 = "";
      };

      shellAliases = {
        update        = "sudo nixos-rebuild switch --upgrade && echo ------------ && nix-channel --update && echo ------------ && home-manager switch";

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

        n             = "vim ~/s/notes/$(date +work-%Y-%W).md";
        N             = "vim ~/s/notes/$(date +home-%Y).md";
        s             = "vim ~/s/notes/scratch.md";
        v             = "vim";
      };
    };
  };
}
