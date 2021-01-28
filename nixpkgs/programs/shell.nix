{ config, pkgs, ... }:
{
  programs = {

    direnv.enable = true;

    powerline-go = {
      enable = true;
      modules = [ "ssh" "host" "cwd" "venv" "git" "perms" "nix-shell" ];
      newline = true;
      settings = {
        colorize-hostname = true;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;

      initExtra = ''
        # Only change to src if in root of $HOME or WSL home
        # This way Kitty can open new tabs in the same dir
        if [[ "$(pwd)" == "$HOME"  ]] || [[ "$(pwd)" == "/mnt/c/Users/nelso" ]] then
          cd ~/src
        fi

        # Single tab complete
        #unsetopt listambiguous
        setopt menu_complete
      '';

      sessionVariables = {
        EDITOR="nvim";
      };

      shellAliases = {
        playDronezone       = "clear;echo -e '\033[36mPlaying dronezone';somafm play dronezone";
        playMissioncontrol  = "clear;echo -e '\033[36mPlaying missioncontrol';somafm play missioncontrol";
        playSf1033          = "clear;echo -e '\033[36mPlaying sf1033';somafm play sf1033";

        uc            = "kubectx";
        k             = "kubectl";
        kns           = "kubens";
        osx-flushdns  = "sudo killall -v -HUP mDNSResponder";
        osx-update    = "sudo softwareupdate --install --all --verbose --restart";
        src           = "cd ~/src";
        vim           = "nvim";
      };
    };
  };
}
