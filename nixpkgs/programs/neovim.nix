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
          gruvbox-community
          vim-startify
          #gruvbox-nvim
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
          " Show modified tracked files in git
          function! s:gitModified()
            let files = systemlist('git ls-files -m 2>/dev/null')
            return map(files, "{'line': v:val, 'path': v:val}")
          endfunction

          " same as above, but show untracked files, honouring .gitignore
          function! s:gitUntracked()
            let files = systemlist('git ls-files -o --exclude-standard 2>/dev/null')
            return map(files, "{'line': v:val, 'path': v:val}")
          endfunction

          " when starting [n]vim without a file, open vim-startify and show
          "   1. most recent files in current working dir
          "   2. git modified and tracked files
          "   3. git untracked files
          "   4. most recent files globaly
          let g:startify_lists = [
              \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
              \ { 'type': function('s:gitModified'),  'header': ['   git modified']},
              \ { 'type': function('s:gitUntracked'), 'header': ['   git untracked']},
              \ { 'type': 'files',     'header': ['   MRU']            },
              \ ]

          " Dont show vim-startify banner with quote and cow
          let g:startify_custom_header = []

          " default nvim-compe config
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

          " Set leader:
          map , <Leader>

          " setup colorschemes
          set background=light
          set termguicolors
          let g:airline_theme           = 'monochrome'
          let g:gruvbox_contrast_dark   = 'hard'
          let g:gruvbox_contrast_light  = 'hard'
          let g:gruvbox_italic          = '1'
          colorscheme                     gruvbox
          nnoremap <silent> <Leader>,d :set background=dark<CR>
          nnoremap <silent> <Leader>,l :set background=light<CR>

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

          autocmd bufreadpre *.md setlocal shiftwidth=4
          autocmd bufreadpre *.md setlocal softtabstop=4

          " Use case-insensitive search
          set ignorecase

          " helpfull popup for shortcuts
          set timeoutlen=500
          lua << EOF
            require("which-key").setup {}
          EOF

          set conceallevel=2

          " cant spell
          set spelllang=en
          "nnoremap <silent> <Leader>s :call ToggleSpellCheck()<CR>

        '';
    };
  };
}
