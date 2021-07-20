{ config, pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins =
        with pkgs.vimPlugins; [
          #gina-vim
          #neorg
          #neovim-sensible
          #nvim-lspconfig
          #nvim-lspconfig
          #packer-nvim
          #plenary-nvim
          #vim-gitgutter
          #vim-grammarous
          #gruvbox-community
          vim-startify
          gruvbox-nvim
          nvim-compe              # autocomplete
          vim-airline
          vim-airline-themes
          vim-better-whitespace
          vim-lastplace
          vim-nix
          vim-signify
          vim-table-mode
          which-key-nvim
        ];

      extraConfig = ''

        set completeopt=menuone,noselect
        let g:compe = {}
        let g:compe.enabled = v:true
        let g:compe.autocomplete = v:true
        let g:compe.debug = v:false
        let g:compe.min_length = 1
        let g:compe.preselect = 'enable'
        let g:compe.throttle_time = 80
        let g:compe.source_timeout = 200
        let g:compe.resolve_timeout = 800
        let g:compe.incomplete_delay = 400
        let g:compe.max_abbr_width = 100
        let g:compe.max_kind_width = 100
        let g:compe.max_menu_width = 100
        let g:compe.documentation = v:true

        let g:compe.source = {}
        let g:compe.source.path = v:true
        let g:compe.source.buffer = v:true
        let g:compe.source.calc = v:true
        let g:compe.source.nvim_lsp = v:true
        let g:compe.source.nvim_lua = v:true
        let g:compe.source.vsnip = v:true
        let g:compe.source.ultisnips = v:true
        let g:compe.source.luasnip = v:true
        let g:compe.source.emoji = v:true

        " set title in Kitty term tab to just the filename
        set titlestring=%t
        set title

        " github markdown compat table mode

        " enable true color
        set termguicolors
        set background=light
        let g:gruvbox_contrast_dark = 'hard'
        let g:gruvbox_contrast_light = 'hard'
        colorscheme gruvbox
        let g:airline_theme='monochrome'
        nnoremap <silent> <Leader>,d :set background=dark<CR>
        nnoremap <silent> <Leader>,l :set background=light<CR>

        " Set leader:
        map , <Leader>

        " Copy all to clipboard
        nnoremap <silent> <Leader>,c :%y+<CR>
        set clipboard=unnamedplus

        " TableModeToggle
        nnoremap <silent> <Leader>,t :TableModeToggle<CR>
        let g:table_mode_corner='|'

        " enable mouse
        set mouse=a

        set updatetime=75

        " Indentation settings for using 2 spaces instead of tabs.
        set shiftwidth=2
        set softtabstop=2
        set expandtab

        " Use case-insensitive search
        set ignorecase

        " helpfull popup for shortcuts
        set timeoutlen=500
        lua << EOF
          require("which-key").setup {}
        EOF

        " cant spell
        set spelllang=en
        "nnoremap <silent> <Leader>s :call ToggleSpellCheck()<CR>

        '';
    };
  };
}
