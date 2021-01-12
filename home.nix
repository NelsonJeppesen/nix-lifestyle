{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  
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
      pkgs.gnomeExtensions.paperwm
      pkgs.wmctrl
      pkgs.google-chrome
      pkgs.google-chrome-beta
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
        tab_bar_min_tabs            = "1";
        tab_bar_style               = "powerline";
        tab_title_template          = " {index} ";

#        # BirdsOfParadise
#        background            = "#2a1e1d";
#        color0                = "#573d25";
#        color1                = "#be2d26";
#        color10               = "#94d7ba";
#        color11               = "#d0d04f";
#        color12               = "#b8d3ed";
#        color13               = "#d09dca";
#        color14               = "#92ced6";
#        color15               = "#fff9d4";
#        color2                = "#6ba08a";
#        color3                = "#e99c29";
#        color4                = "#5a86ac";
#        color5                = "#ab80a6";
#        color6                = "#74a5ac";
#        color7                = "#dfdab7";
#        color8                = "#9a6b49";
#        color9                = "#e84526";
#        cursor                = "#573d25";
#        foreground            = "#dfdab7";
#        selection_background  = "#563c27";
#        selection_foreground  = "#2a1e1d";
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
