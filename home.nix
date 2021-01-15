{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  dconf.settings = {
    "org/gnome/shell" = {
      #disabled-extensions = [];
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "paperwm@hedning:matrix.org"
      ];
    };

    "org/gnome/shellextensions/paperwm" = {
      horizontal-margin       = 0;
      vertical-margin         = 0;
      vertical-margin-bottom  = 0;
      window-gap              = 0;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_R";
    };

    "org/gnome/shell/keybindings" = {
      toggle-overview  =  [];
    };

    "org/gnome/desktop/interface" = {
      gtk-theme   = "Adwaita-dark";
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:super" ];
    };

    # Focus apps if running else launch
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>backslash";
      command = "bash -c \"wmctrl -xa kitty ; [ \"$?\" == \"1\" ] && kitty\"";
      name    = "kitty";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>s";
      command = "bash -c \"wmctrl -a slack; [ \"$?\" == \"1\" ] && slack\"";
      name    = "slack";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>x";
      command = "bash -c \"wmctrl -xa chrome/work; [ \"$?\" == \"1\" ] && google-chrome-stable --user-data-dir=$HOME/.config/chrome/work\"";

      name    = "google-chrome-work";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Super>b";
      command = "bash -c \"wmctrl -xa chrome/personal; [ \"$?\" == \"1\" ] && google-chrome-stable --user-data-dir=$HOME/.config/chrome/personal \"";
      name    = "google-chrome-personal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding = "<Super>z";
      command = "bash -c \"wmctrl -xa spotify; [ \"$?\" == \"1\" ] && spotify\"";
      name    = "spotify";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      binding = "<Super>j";
      command = "bash -c \"wmctrl -xa web.whatsapp; [ \"$?\" == \"1\" ] && google-chrome-stable -user-data-dir=$HOME/.config/chrome/whatsapp --app=https://web.whatsapp.com \"";
      name    = "google-chrome-whatsapp";
    };

    # map the mappings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
      ];
    };
  };
  
  home = {

    packages = [
      #pkgs.aws-iam-authenticator
      pkgs.awscli2
      pkgs.curl
      pkgs.helmfile
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.ssm-session-manager-plugin
      pkgs.ripgrep
      pkgs.rnix-lsp
      pkgs.terraform_0_13
      pkgs.wget
      pkgs.gnomeExtensions.appindicator
      pkgs.gnomeExtensions.caffeine
      pkgs.gnomeExtensions.paperwm
      pkgs.gnomeExtensions.clipboard-indicator
      pkgs.wmctrl
      pkgs.google-chrome
      pkgs.slack
      pkgs.spotify
      pkgs.dnsutils
      pkgs.sops
    ];
  };

  programs = {
    home-manager.enable = true;

    kitty = { 
      enable = true;
      
      keybindings = {
        "cmd+0" = "goto_tab 10";
        "cmd+1" = "goto_tab 1";
        "cmd+2" = "goto_tab 2";
        "cmd+3" = "goto_tab 3";
        "cmd+4" = "goto_tab 4";
        "cmd+5" = "goto_tab 5";
        "cmd+6" = "goto_tab 6";
        "cmd+7" = "goto_tab 7";
        "cmd+8" = "goto_tab 8";
        "cmd+9" = "goto_tab 9";
        "cmd+w" = "close_window";
        "ctrl+shift+enter" =  "launch --cwd=current";
      };

      settings = {
        copy_on_select              = true;
        background_opacity          = "0.96";
        enable_audio_bell           = false;
        font_size                   = "12.0";
        update_check_interval       = "24";
        hide_window_decorations     = true ;
        macos_show_window_title_in  = "none" ;
        scrollback_lines            = "10000";
        strip_trailing_spaces       = "smart";
        #tab_bar_min_tabs            = "1";
        tab_bar_style               = "powerline";
        tab_title_template          = " {index} ";

        background            = "#181c27";
        foreground            = "#ada37a";
        cursor                = "#91805a";
        selection_background  = "#172539";
        color0                = "#181818";
        color8                = "#555555";
        color1                = "#800009";
        color9                = "#ab3834";
        color2                = "#48513b";
        color10               = "#a6a65d";
        color3                = "#cc8a3e";
        color11               = "#dcde7b";
        color4                = "#566d8c";
        color12               = "#2f97c6";
        color5                = "#724c7c";
        color13               = "#d33060";
        color6                = "#5b4f4a";
        color14               = "#f3dab1";
        color7                = "#ada37e";
        color15               = "#f3f3f3";
        selection_foreground  = "#181c27";

      };
    };

    powerline-go = {
      enable = true;
      modules = [ "venv" "ssh" "git" "cwd" "perms" ];
      #settings = {
      #  mode = "flat";
      #};
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
        ctx           = "kubectx";
        k             = "kubectl";
        kns           = "kubens";
        osx-flushdns  = "sudo killall -v -HUP mDNSResponder";
        osx-update    = "sudo softwareupdate --install --all --verbose --restart";
        src           = "cd ~/src";
        vim           = "nvim";
      };
    };

    direnv.enable = true;

    git = {
      enable = true;
      userName = "Nelson Jeppesen";
      userEmail = "50854675+NelsonJeppesen@users.noreply.github.com";

      ignores = [
        # ignore direv files
        ".envrc"
      ];

      extraConfig = {
        pull = { 
          ff       = "only";     
        };

        push = { 
          default  = "current";  
        };

        color = {
          diff        = "auto";
          status      = "auto";
          branch      = "auto";
          interactive = "auto";
          ui          = true;
          pager       = true;
        };

      };

      aliases = {
        a     = "add";
        co    = "checkout";
        ct    = "commit";
        some  = "!git fetch -a && git pull";
        ps    = "push";
        psf   = "push --force-with-lease";
        s     = "status";
        st    = "stash";
        stp   = "stash pop";
        stc   = "stash clear";
        dfm   = "diff origin/master";
        l     = "log -p --color";
        l1    = "log -1 HEAD";
        rb    = "rebase -i HEAD~9";
        rba   = "rebase --abort";
        rbc   = "rebase --continue";
      };
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      #defaultEditor = true;

      configure = {

        customRC = ''
          " enable true color
          set termguicolors
          colorscheme gruvbox

          " autocompletion (deoplete)
          inoremap <silent><expr> <Tab>  pumvisible() ? "<C-n>" : "<Tab>"
          let g:deoplete#enable_at_startup = 1

          " copy everything to the clipboard
          command! CopyToClipboard :%y+

          " Set leader:
          map , <Leader>
          set updatetime=70
          let g:ale_sign_column_always = 1

          " Indentation settings for using 2 spaces instead of tabs.
          set shiftwidth=2
          set softtabstop=2
          set expandtab

          " Use case-insensitive search
          set ignorecase

          " cant spell
          set spelllang=en
          nnoremap <silent> <Leader>s :call ToggleSpellCheck()<CR>
        '';

        packages.myVimPackage = {
          start = with pkgs.vimPlugins; [
            ale
            deoplete-nvim
            gruvbox-community
            neovim-sensible
            #nvim-lspconfig
            vim-airline
            vim-airline-themes
            vim-gitgutter
            vim-nix
          ] ;
        };
      };
    };
  };
}
