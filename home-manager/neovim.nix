# NeoVim for daily work and daily notes
{ config, pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins =
        with pkgs.vimPlugins; [

          copilot-cmp
          {
            plugin = copilot-lua;
            type = "lua";
            config = ''
              require("copilot").setup({
                suggestion = { enabled = false },
                panel = { enabled = false },
              })
              require("copilot_cmp").setup()
            '';
          }

          {
            plugin = mini-nvim;
            type = "lua";
            config = ''
              require('mini.animate').setup()
              require('mini.basics').setup({ options = { extra_ui = true }})
              require('mini.comment').setup()
              require('mini.surround').setup()
              require('mini.trailspace').setup()
            '';
          }

          {
            plugin = zephyr-nvim;
            type = "lua";
            config = "require('zephyr')";
          }

          # Install tree-sitter with all the plugins/grammars
          #   https://tree-sitter.github.io/tree-sitter
          {
            plugin = nvim-treesitter.withAllGrammars;
            type = "lua";
            config = ''
              require'nvim-treesitter.configs'.setup {
                highlight = {enable = true, additional_vim_regex_highlighting = false}
               }
            '';
          }

          # https://github.com/iamcco/markdown-preview.nvim/
          #   "markdown preview plugin for (neo)vim"
          markdown-preview-nvim

          # https://github.com/gpanders/editorconfig.nvim
          #  "EditorConfig plugin for Neovim"
          editorconfig-nvim

          # https://github.com/sudormrfbin/cheatsheet.nvim
          #  "A cheatsheet plugin for neovim with bundled cheatsheets for the
          #   editor, multiple vim plugins, nerd-fonts, regex, etc. with a
          #   Telescope fuzzy finder interface!"
          cheatsheet-nvim # Provides <Leader>? help

          # https://github.com/akinsho/bufferline.nvim
          #  "A snazzy bufferline for Neovim"
          {
            plugin = bufferline-nvim;
            type = "viml";
            config = ''
              lua require("bufferline").setup{}
              nnoremap <silent> <C-h> :BufferLineCyclePrev<CR>
              nnoremap <silent> <C-l> :BufferLineCycleNext<CR>
            '';
          }

          # https://github.com/kyazdani42/nvim-web-devicons
          #   "lua `fork` of vim-web-devicons for neovim"
          nvim-web-devicons # used by bufferline-nvim


          {
            plugin = nvim-neoclip-lua;
            type = "lua";
            config = "require('neoclip').setup()";
          }

          # https://github.com/nvim-telescope/telescope.nvim
          #   "highly extendable fuzzy finder over lists"
          {
            plugin = telescope-nvim;
            type = "viml";
            config = ''
              nnoremap  ,fg  :execute 'Telescope git_files cwd=' . expand('%:p:h')<cr>
              nnoremap  ,ff  <cmd>lua require('telescope.builtin').find_files()<cr>
              nnoremap  ,f/  <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>
              nnoremap  ,fb  <cmd>lua require('telescope.builtin').buffers()<cr>
              nnoremap  ,fo  <cmd>lua require('telescope.builtin').file_browser()<cr>
              nnoremap  ,fh  <cmd>lua require('telescope.builtin').oldfiles()<cr>
              nnoremap  ,fc  <cmd>lua require('telescope.builtin').colorscheme()<cr>
              nnoremap  ,fr  <cmd>lua require('telescope.builtin').registers()<cr>
              nnoremap  ,p   <cmd>Telescope neoclip<cr>

              lua << EOF
                _G.open_telescope = function()
                  local first_arg = vim.v.argv[2]
                  if first_arg and vim.fn.isdirectory(first_arg) == 1 then
                    vim.g.loaded_netrw = true
                    require("telescope.builtin").find_files({search_dirs = {first_arg}})
                  end
                end

                vim.api.nvim_exec([[
                  augroup TelescopeOnEnter
                    autocmd!
                    autocmd VimEnter * lua open_telescope()
                  augroup END
                ]], false)

                require('telescope').load_extension('neoclip')
              EOF
            '';
          }

          # https://github.com/akinsho/toggleterm.nvim
          #   "A neovim plugin to persist and toggle multiple terminals during an editing session"
          {
            plugin = toggleterm-nvim;
            type = "viml";
            config = ''
              lua << EOF
              require("toggleterm").setup{
                direction = 'float',
                winblend = 3,
                float_opts = {border = 'curved'}
              }
              EOF
              nnoremap <silent> <c-\>     <cmd>execute 'ToggleTerm direction=float      dir=' . expand('%:p:h')<cr>
              nnoremap <silent> <S-c-\>   <cmd>execute 'ToggleTerm direction=horizontal dir=' . expand('%:p:h')<cr>
              inoremap <silent> <c-\>     <esc><cmd>execute 'ToggleTerm dir=' . expand('%:p:h')<cr>
              tnoremap <silent> <c-\>     <esc><cmd>ToggleTerm<cr>
              tnoremap <silent> <S-c-\>   <esc><cmd>ToggleTerm<cr>
            '';
          }

          # https://github.com/mhartington/formatter.nvim
          #   "A format runner for neovim, written in lua"
          {
            plugin = neoformat;
            type = "lua";
            config = "vim.api.nvim_set_keymap('n', ',a', ':Neoformat<cr>',{noremap = true})";
          }

          # https://github.com/f-person/git-blame.nvim
          #   "A git blame plugin for Neovim written in Lua"
          {
            plugin = git-blame-nvim;
            type = "lua";
            config = ''
              vim.g["gitblame_enabled"] = 0
              vim.api.nvim_set_keymap('n', ',,b', ':GitBlameToggle<cr>',{noremap = true})
            '';
          }

          # https://github.com/lewis6991/gitsigns.nvim
          #   "Super fast git decorations implemented purely in lua/teal"
          {
            plugin = gitsigns-nvim;
            type = "viml";
            config = "lua require('gitsigns').setup()";
          }

          # https://github.com/hoob3rt/lualine.nvim
          #   "A blazing fast and easy to configure neovim statusline written in pure lua"
          {
            plugin = lualine-nvim;
            type = "lua";
            config = ''
              require('lualine').setup {
                options = {
                  section_separators = " ",
                  component_separators = " "
                }
              }
            '';
          }

          # https://github.com/hrsh7th/nvim-cmp
          #   "A completion plugin for neovim coded in Lua"
          cmp-buffer
          cmp-nvim-lsp
          cmp-path
          cmp-treesitter
          {
            plugin = nvim-cmp;
            type = "lua";
            config = ''
              local cmp = require'cmp'
              cmp.setup({

                sources = cmp.config.sources({
                 { name = "copilot"     },
                 { name = 'buffer'      },
                 { name = 'path'        },
                 { name = 'treesitter'  },
                }),

                window = {
                  completion    = cmp.config.window.bordered(),
                  documentation = cmp.config.window.bordered(),
                },

                formatters = { insert_text = require("copilot_cmp.format").remove_existing},

                mapping = {
                  ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                  ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                  ["<CR>"] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Replace,select = false}),
                },
              })
            '';
          }

          # https://github.com/folke/which-key.nvim
          #   "displays a popup with possible keybindings of the command you started typing"
          {
            plugin = which-key-nvim;
            type = "lua";
            config = "require('which-key').setup()";
          }

          # https://github.com/tjdevries/train.nvim
          #   "Train yourself with vim motions and make your own train tracks :)"
          {
            plugin = train-nvim;
            type = "viml";
            config = ''
              nnoremap  ,tu  :TrainUpDown<cr>
              nnoremap  ,tw  :TrainWord<cr>
              nnoremap  ,to  :TrainTextObj<cr>
            '';
          }

          # https://github.com/nacro90/numb.nvim/
          #   "Peek lines just when you intend"
          {
            plugin = numb-nvim;
            type = "lua";
            config = "require('numb').setup()";
          }

          # ------------------------------------ Vimscript Plugins ---------------------------------------------
          # https://github.com/lambdalisue/vim-manpager
          #  "Use Vim as a MANPAGER program"
          # see shell.nix
          #vim-manpager

          # https://github.com/farmergreg/vim-lastplace
          #   "Intelligently reopen files at your last edit position in Vim"
          vim-lastplace

          {
            plugin = undotree;
            type = "lua";
            config = "vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)";
          }

          # https://github.com/dhruvasagar/vim-table-mode
          #   "VIM Table Mode for instant [ASCII] table creation"
          {
            plugin = vim-table-mode;
            type = "viml";
            config = ''
              " Make tables github markdown compatable
              let g:table_mode_corner='|'
              nnoremap  <silent>  ,,a   :TableModeToggle<cr>
            '';
          }
        ];

      extraConfig = ''
        let theme =  system('dconf read /org/gnome/desktop/interface/color-scheme')
        if theme =~ ".*default.*"
          colorscheme dayfox
        end

        set clipboard=unnamedplus

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

        set autoread
        let mapleader=","
        nnoremap <silent>   <leader><leader>n   Go<cr><esc>:r! date +\%Y-\%m-\%d<cr>I# <esc>o*<space>
        nnoremap            <leader><leader>c   :%y+<cr>
        nnoremap            <leader>d           :% !base64 -d<cr>

        " persistent undo
        if !isdirectory($HOME."/.config/nvim/undo")
            call mkdir($HOME."/.config/nvim/undo", "", 0700)
        endif
        set undodir=~/.config/nvim/undo

        " enable mouse
        set updatetime=75

        " Indentation settings for using 2 spaces instead of tabs.
        set shiftwidth=2
        set softtabstop=2
        set expandtab

        " helpfull popup for shortcuts
        set timeoutlen=500

        " cant spell
        set spell
        set spelllang=en

        " disable swp
        set noswapfile
      '';
    };
  };
}
