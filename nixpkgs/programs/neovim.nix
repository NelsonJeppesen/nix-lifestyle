{ config, pkgs, ... }:
{
  programs = {

    neovim = {
      enable       = true;
      viAlias      = true;
      vimAlias     = true;
      vimdiffAlias = true;

      plugins =
        with pkgs.vimPlugins; [
          # Lua NeoVIm plugins
          #barbar-nvim
          #nvim-treesitter
          #nvim-web-devicons
          #registers-nvim

          formatter-nvim  # generic formatter
          git-blame-nvim  # <leader><leader>f
          gitsigns-nvim   # Git gutter
          lualine-nvim    # status line
          nvim-compe      # autocomplete
          scrollbar-nvim
          train-nvim
          which-key-nvim
          #indent-blankline-nvim

          # Legacy Vimscript Plugins
          #goyo-vim              # focus
          #gruvbox-community     # theme;
          nord-nvim
          vim-better-whitespace
          vim-lastplace         # remember location in file
          vim-nix
          vim-table-mode
        ];

        extraConfig = ''
          set autoread
          let mapleader=","
          nnoremap            <leader><leader>b   :GitBlameToggle<CR>
          nnoremap            <leader><leader>c   :%y+<CR>
          nnoremap            <leader><leader>d   :set background=dark<CR>
          nnoremap            <leader><leader>l   :set background=light<CR>
          nnoremap            <leader><leader>s   :StripWhitespace<CR>
          nnoremap  <silent>  <leader><leader>f   :Format<CR>
          nnoremap  <silent>  <leader><leader>t   :TableModeToggle<CR>
          nnoremap  <silent>  <leader><leader>z   :call ToggleHiddenAll()<CR>

          " https://github.com/tjdevries/train.nvim/
          nnoremap            <leader>tu          :TrainUpDown<CR>
          nnoremap            <leader>tw          :TrainWord<CR>
          nnoremap            <leader>to          :TrainTextObj<CR>

          let s:hidden_all = 0
          function! ToggleHiddenAll()
              if s:hidden_all  == 0
                  let s:hidden_all = 1
                  set noshowmode
                  set noruler
                  set laststatus=0
                  set noshowcmd
              else
                  let s:hidden_all = 0
                  set showmode
                  set ruler
                  set laststatus=2
                  set showcmd
              endif
          endfunction

          "set colorcolumn=120

          let g:compe = {}
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

          " Show `▸▸` for tabs: 	, `·` for tailing whitespace:
          set list listchars=tab:▸▸,trail:·

          augroup ScrollbarInit
            autocmd!
            autocmd CursorMoved,VimResized,QuitPre * silent! lua require('scrollbar').show()
            autocmd WinEnter,FocusGained           * silent! lua require('scrollbar').show()
            autocmd WinLeave,BufLeave,BufWinLeave,FocusLost            * silent! lua require('scrollbar').clear()
          augroup end

          let g:scrollbar_shape = {
              \ 'head': '░',
              \ 'body': '░',
              \ 'tail': '░',
              \ }

          let g:gitblame_enabled = 0
          lua << EOF
            require('formatter').setup({
              logging = false,
              filetype = {
                tf = {
                  function()
                  return {
                    exe = "terraform",
                    args = {"fmt", '-'},
                    stdin = true
                  }
                  end
                },
                yaml = {
                  function()
                  return {
                    exe = 'yq',
                    args = {'--yaml-output','.'},
                    stdin = true
                  }
                  end
                }
              }
            })
          EOF

          " set title in Kitty term tab to just the filename
          set titlestring=%t
          set title

          " setup colorschemes
          "set background=light
          set termguicolors
          "let g:gruvbox_contrast_dark   = 'hard'
          "let g:gruvbox_contrast_light  = 'hard'
          "let g:gruvbox_italic          = '1'
          colorscheme                     nord
          hi Normal guibg=NONE ctermbg=NONE

          " Copy all to clipboard
          set clipboard=unnamedplus

          " TableModeToggle
          let g:table_mode_corner='|'

          " enable mouse
          set mouse=a

          set updatetime=75


          " Indentation settings for using 2 spaces instead of tabs.
          set shiftwidth=2
          set softtabstop=2
          set expandtab

          "Autosave file when working on markdown (my notes)
          autocmd bufreadpre ~/s/notes/*  :autocmd  TextChanged,TextChangedI <buffer> silent write
          autocmd bufreadpre ~/s/notes/*            :set noswapfile
          autocmd bufreadpre ~/s/notes/*            setlocal shiftwidth=4
          autocmd bufreadpre ~/s/notes/*            setlocal softtabstop=4

          " Use case-insensitive search
          set ignorecase

          " helpfull popup for shortcuts
          set timeoutlen=500

          set conceallevel=2
          " #require'nvim-treesitter.configs'.setup {}
          lua << EOF
            require("which-key").setup {}
            require('gitsigns').setup()
            require('lualine').setup {
              options = {
                theme = "horizon",
                section_separators = "",
                component_separators = ""
              }
            }
          EOF
          "theme = 'gruvbox_light',

          let g:better_whitespace_guicolor='#cccccc'

          " cant spell
          set spelllang=en

          autocmd vimenter * hi Normal guibg=NONE ctermbg=NONE
        '';
    };
  };
}
