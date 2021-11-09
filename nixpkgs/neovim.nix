# NeoVim for daily work and daily notes
# prefer Lua built NeoVim plugins when possible

{ config, pkgs, ... }:
{
  programs = {

    neovim = {
      enable       = true;
      viAlias      = true;
      vimAlias     = true;
      vimdiffAlias = true;

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins =
        with pkgs.vimPlugins; [
          # -------------------------------------- Lua Plugins -------------------------------------------------

          # https://github.com/karb94/neoscroll.nvim/
          #   "Smooth scrolling neovim plugin written in lua"
          { plugin = neoscroll-nvim;
            config = "lua require('neoscroll').setup({})";
          }

          # https://github.com/SidOfc/mkdx/
          #   "A vim plugin that adds some nice extra's for working with markdown documents"
          mkdx

          # https://github.com/shaunsingh/nord.nvim
          #   "Neovim theme based off of the Nord Color Palette, written in lua with tree sitter support"
          #nord-nvim
          { plugin = nord-vim;
            config = ''
              set background=dark
              set termguicolors
              colorscheme nord
            '';
          }

          # https://github.com/eddyekofo94/gruvbox-flat.nvim/
          #   "Another attempt of a flat Gruvbox theme for Neovim"
          gruvbox-flat-nvim

          # https://github.com/nvim-telescope/telescope.nvim
          #   "highly extendable fuzzy finder over lists"
          telescope-nvim

          # https://github.com/akinsho/toggleterm.nvim
          #   "A neovim plugin to persist and toggle multiple terminals during an editing session"
          { plugin = toggleterm-nvim;
            config = ''
              lua << EOF
              require("toggleterm").setup{
                direction = 'float',
                winblend = 3,
                float_opts = {border = 'curved'}
              }
              EOF
              nnoremap  <silent>  <c-\>      <cmd>execute 'ToggleTerm dir=' . expand('%:p:h')<cr>
              inoremap  <silent>  <c-\> <esc><cmd>execute 'ToggleTerm dir=' . expand('%:p:h')<cr>
              tnoremap  <silent>  <c-\> <esc><cmd>ToggleTerm<cr>
            '';
          }

          # https://github.com/mhartington/formatter.nvim
          #   "A format runner for neovim, written in lua"
          { plugin = formatter-nvim;
            config = ''
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
            '';
          }

          # https://github.com/f-person/git-blame.nvim
          #   "A git blame plugin for Neovim written in Lua"
          git-blame-nvim

          # https://github.com/lewis6991/gitsigns.nvim
          #   "Super fast git decorations implemented purely in lua/teal"
          { plugin = gitsigns-nvim;
            config = "lua require('gitsigns').setup()";
          }

          # https://github.com/hoob3rt/lualine.nvim
          #   "A blazing fast and easy to configure neovim statusline written in pure lua"
          { plugin = lualine-nvim;
            config = ''
              lua << EOF
              require('lualine').setup {
                options = {
                  theme = "horizon",
                  section_separators = "",
                  component_separators = ""
                }
              }
              EOF
            '';
          }

          # https://github.com/hrsh7th/nvim-cmp
          #   "A completion plugin for neovim coded in Lua"
          cmp-path    # cmp plugin, file path
          cmp-buffer  # cmp plugin, buffer
          cmp-emoji   # cmp plugin, emoji
          { plugin = nvim-cmp;
            config = ''
              lua << EOF
              local cmp = require'cmp'
              require('cmp').setup({
                sources = {
                  { name = 'buffer' },
                  { name = 'path'},
                  { name = 'emoji'},
                },
                mapping = {
                  ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item()),
                }
              })
              EOF
            '';
          }

          # https://github.com/folke/which-key.nvim
          #   "displays a popup with possible keybindings of the command you started typing"
          { plugin = which-key-nvim;
            config = "lua require('which-key').setup()";
          }

          # https://github.com/tjdevries/train.nvim
          #   "Train yourself with vim motions and make your own train tracks :)"
          train-nvim

          # ------------------------------------ Vimscript Plugins ---------------------------------------------

          # https://github.com/farmergreg/vim-lastplace
          #   "Intelligently reopen files at your last edit position in Vim"
          vim-lastplace

          # https://github.com/ntpeters/vim-better-whitespace
          #   "Better whitespace highlighting for Vim"
          { plugin = vim-better-whitespace;
            config = ''
              let g:better_whitespace_guicolor='#556e87'
              set list listchars=tab:▸▸,trail:·
            '';
          }


          # https://github.com/LnL7/vim-nix/
          #   "Vim configuration files for Nix"
          vim-nix

          # https://github.com/dhruvasagar/vim-table-mode
          #   "VIM Table Mode for instant [ASCII] table creation"
          vim-table-mode
        ];

        extraConfig = ''
          " Hard mode
          " Remove newbie crutches in Command Mode
          cnoremap <Down> <Nop>
          cnoremap <Left> <Nop>
          cnoremap <Right> <Nop>
          cnoremap <Up> <Nop>

          " Remove newbie crutches in Insert Mode
          inoremap <Down> <Nop>
          inoremap <Left> <Nop>
          inoremap <Right> <Nop>
          inoremap <Up> <Nop>

          " Remove newbie crutches in Normal Mode
          nnoremap <Down> <Nop>
          nnoremap <Left> <Nop>
          nnoremap <Right> <Nop>
          nnoremap <Up> <Nop>

          " Remove newbie crutches in Visual Mode
          vnoremap <Down> <Nop>
          vnoremap <Left> <Nop>
          vnoremap <Right> <Nop>
          vnoremap <Up> <Nop>

          set signcolumn=yes " always show gutter

          "function InsertIfEmpty()
          "    if @% == ""
          "        " No filename for current buffer
          "        Telescope find_files
          "    endif
          "endfunction

          " Show search/replace in real-time
          set inccommand=nosplit

          "au VimEnter * call InsertIfEmpty()

          set autoread
          let mapleader=","
          nnoremap <silent>   <leader><leader>n   Go<cr><esc>:r! date<cr>I# <esc>o##<space>
          nnoremap            <leader><leader>b   :GitBlameToggle<cr>
          nnoremap            <leader><leader>c   :%y+<cr>
          nnoremap            <leader><leader>d   :set background=dark<cr>
          nnoremap            <leader><leader>l   :set background=light<cr>
          nnoremap            <leader><leader>s   :StripWhitespace<cr>
          nnoremap  <silent>  <leader><leader>f   :Format<cr>
          nnoremap  <silent>  <leader><leader>a   :TableModeToggle<cr>
          nnoremap  <silent>  <leader><leader>z   :call ToggleHiddenAll()<cr>

          " avoid using :
          nnoremap  <silent>  <leader>qq          :q!<cr>
          nnoremap  <silent>  <leader>ww          :w<cr>
          nnoremap  <silent>  <leader>wq          :wq<cr>

          " keep terminal in background
          set hidden



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
          nnoremap            <leader>tu          :TrainUpDown<cr>
          nnoremap            <leader>tw          :TrainWord<cr>
          nnoremap            <leader>to          :TrainTextObj<cr>

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
          set number
          set relativenumber

          let g:gitblame_enabled = 0

          " set title in Kitty term tab to just the filename
          set titlestring=%t
          set title

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
          autocmd bufreadpre ~/s/notes/*            set signcolumn=no

          " Use case-insensitive search
          set ignorecase

          " helpfull popup for shortcuts
          set timeoutlen=500

          set conceallevel=2

          " cant spell
          set spelllang=en
        '';
    };
  };
}
