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
          # -------------------------------------- Lua Plugins -------------------------------------------------

          # https://github.com/shaunsingh/nord.nvim
          #   "Neovim theme based off of the Nord Color Palette, written in lua with tree sitter support"
          nord-nvim

          # https://github.com/nvim-telescope/telescope.nvim
          #   "highly extendable fuzzy finder over lists"
          telescope-nvim

          # https://github.com/akinsho/toggleterm.nvim
          #   "A neovim plugin to persist and toggle multiple terminals during an editing session"
          toggleterm-nvim

          # https://github.com/mhartington/formatter.nvim
          #   "A format runner for neovim, written in lua"
          formatter-nvim

          # https://github.com/f-person/git-blame.nvim
          #   "A git blame plugin for Neovim written in Lua"
          git-blame-nvim

          # https://github.com/lewis6991/gitsigns.nvim
          #   "Super fast git decorations implemented purely in lua/teal"
          gitsigns-nvim

          # https://github.com/hoob3rt/lualine.nvim
          #   "A blazing fast and easy to configure neovim statusline written in pure lua"
          lualine-nvim

          # https://github.com/hrsh7th/nvim-cmp
          #   "A completion plugin for neovim coded in Lua"
          nvim-cmp    # core
          cmp-path    # cmp plugin, file path
          cmp-buffer  # cmp plugin, buffer
          cmp-emoji   # cmp plugin, emoji

          # https://github.com/folke/which-key.nvim
          #   "displays a popup with possible keybindings of the command you started typing"
          which-key-nvim

          # https://github.com/tjdevries/train.nvim
          #   "Train yourself with vim motions and make your own train tracks :)"
          train-nvim

          # ------------------------------------ Vimscript Plugins ---------------------------------------------

          # https://github.com/farmergreg/vim-lastplace
          #   "Intelligently reopen files at your last edit position in Vim"
          vim-lastplace


          # https://github.com/ntpeters/vim-better-whitespace
          #   "Better whitespace highlighting for Vim"
          vim-better-whitespace

          # https://github.com/LnL7/vim-nix/
          #   "Vim configuration files for Nix"
          vim-nix

          # https://github.com/dhruvasagar/vim-table-mode
          #   "VIM Table Mode for instant [ASCII] table creation"
          vim-table-mode
        ];

        extraConfig = ''
          set signcolumn=yes " always show gutter

          function InsertIfEmpty()
              if @% == ""
                  " No filename for current buffer
                  Telescope find_files
              endif
          endfunction

          au VimEnter * call InsertIfEmpty()

          set autoread
          let mapleader=","
          nnoremap <silent>   <leader><leader>n   ggO<cr><esc>:r! date<cr>o<tab>
          nnoremap            <leader><leader>b   :GitBlameToggle<CR>
          nnoremap            <leader><leader>c   :%y+<CR>
          nnoremap            <leader><leader>d   :set background=dark<CR>
          nnoremap            <leader><leader>l   :set background=light<CR>
          nnoremap            <leader><leader>s   :StripWhitespace<CR>
          nnoremap  <silent>  <leader><leader>f   :Format<CR>
          nnoremap  <silent>  <leader><leader>a   :TableModeToggle<CR>
          nnoremap  <silent>  <leader><leader>t   :execute 'ToggleTerm dir=' . expand('%:p:h')<CR>
          nnoremap  <silent>  <leader><leader>z   :call ToggleHiddenAll()<CR>


          "
          " telescope-nvim fast, lisp-jit fuzy finder
          "
          " Fuzzy search through the output of `git ls-files` command in cwd of open file
          " Lists files in your current working directory, respects .gitignore
          nnoremap            <leader>fg          :execute 'Telescope git_files cwd=' . expand('%:p:h')<cr>

          nnoremap            <leader>ff          <cmd>lua require('telescope.builtin').find_files()<cr>
          nnoremap            <leader>f/          <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>
          nnoremap            <leader>fb          <cmd>lua require('telescope.builtin').buffers()<cr>
          nnoremap            <leader>fo          <cmd>lua require('telescope.builtin').file_browser()<cr>
          nnoremap            <leader>fh          <cmd>lua require('telescope.builtin').oldfiles()<cr>
          nnoremap            <leader>fc          <cmd>lua require('telescope.builtin').colorscheme()<cr>
          nnoremap            <leader>fr          <cmd>lua require('telescope.builtin').registers()<cr>

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

          " Show `▸▸` for tabs: 	, `·` for tailing whitespace:
          set list listchars=tab:▸▸,trail:·

          let g:gitblame_enabled = 0

          " set title in Kitty term tab to just the filename
          set titlestring=%t
          set title

          " setup colorschemes
          "set background=light
          set termguicolors
          colorscheme                     nord
          hi Normal guibg=NONE ctermbg=NONE

          " Copy all to clipboard
          set clipboard=unnamedplus

          " Make tables github markdown compatable
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
          "theme = 'gruvbox_light',

          let g:better_whitespace_guicolor='#cccccc'

          " cant spell
          set spelllang=en

          autocmd vimenter * hi Normal guibg=NONE ctermbg=NONE

          " Load my lua configurations
          lua << EOF
            require('local.misc')
            require('local.formatter')
          EOF
        '';
    };
  };

  home.file.".config/nvim/lua/local/misc.lua".text = ''
    require('which-key').setup()
    require('gitsigns').setup()
    require('cmp').setup{
      sources = {
        { name = 'buffer' },
        { name = 'path'},
        { name = 'emoji'},
      }
    }
    require('lualine').setup {
      options = {
        theme = "horizon",
        section_separators = "",
        component_separators = ""
      }
    }
    require("toggleterm").setup{
      direction = 'float',
      float_opts = {
        border = 'curved'
        }
    }
  '';

  home.file.".config/nvim/lua/local/formatter.lua".text = ''
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
  '';

}
