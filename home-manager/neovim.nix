# NeoVim for daily work and daily notes
{ config, pkgs, ... }:
{

  programs = {

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins =
        with pkgs.vimPlugins; [
          # -------------------------- colorschemes ---------------------------
          # highly customizable theme for vim and neovim with support for lsp, treesitter
          # and a variety of plugins
          #   https://github.com/EdenEast/nightfox.nvim
          { plugin = nightfox-nvim; config = "colorscheme nightfox"; }

          # --------------------------Lua Plugins (prefered) ------------------

          # Install tree-sitter with all the plugins/grammars
          #   https://tree-sitter.github.io/tree-sitter
          {
            plugin = (nvim-treesitter.withPlugins (plugins: pkgs.tree-sitter.allGrammars));
            config = ''
              lua << EOF
              require'nvim-treesitter.configs'.setup {
                highlight = {
                  enable = true,
                  additional_vim_regex_highlighting = true
                },
                indent = {
                  enable = true
                },
                incremental_selection = {
                  enable = true,
                  keymaps = {
                    init_selection = "gnn",
                    node_incremental = "grn",
                    scope_incremental = "grc",
                    node_decremental = "grm",
                  },
                },
              }
              EOF

              set foldlevelstart=6
              set foldmethod=expr
              set foldexpr=nvim_treesitter#foldexpr()
            '';
          }

          {
            plugin = mini-nvim;
            config = ''
              lua << EOF
              require('mini.completion').setup({})
              require('mini.trailspace').setup({})
              require('mini.surround').setup({})

              vim.api.nvim_set_keymap('i', '<Tab>',   [[pumvisible() ? "\<C-n>" : "\<Tab>"]],   { noremap = true, expr = true })
              vim.api.nvim_set_keymap('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { noremap = true, expr = true })
              MiniTrailspace.highlight()
              EOF
              nnoremap  ,,s   lua MiniTrailspace.trim()<cr>
            '';
          }

          # https://github.com/iamcco/markdown-preview.nvim/
          #   "markdown preview plugin for (neo)vim"
          markdown-preview-nvim

          # https://github.com/gpanders/editorconfig.nvim
          #  "EditorConfig plugin for Neovim"
          editorconfig-nvim

          {
            plugin = trouble-nvim;
            config = "nnoremap  ,,t  :TroubleToggle<cr>";
          }

          # https://github.com/sudormrfbin/cheatsheet.nvim
          #  "A cheatsheet plugin for neovim with bundled cheatsheets for the
          #   editor, multiple vim plugins, nerd-fonts, regex, etc. with a
          #   Telescope fuzzy finder interface!"
          cheatsheet-nvim # Provides <Leader>? help

          # https://github.com/akinsho/bufferline.nvim
          #  "A snazzy bufferline for Neovim"
          {
            plugin = bufferline-nvim;
            config = ''
              lua require("bufferline").setup{}
              nnoremap <silent> <C-h> :BufferLineCyclePrev<CR>
              nnoremap <silent> <C-l> :BufferLineCycleNext<CR>
            '';
          }

          # https://github.com/kyazdani42/nvim-web-devicons
          #   "lua `fork` of vim-web-devicons for neovim"
          nvim-web-devicons # used by bufferline-nvim

          # https://github.com/karb94/neoscroll.nvim/
          #   "Smooth scrolling neovim plugin written in lua"
          {
            plugin = neoscroll-nvim;
            config = "lua require('neoscroll').setup({})";
          }

          # https://github.com/nvim-telescope/telescope.nvim
          #   "highly extendable fuzzy finder over lists"
          {
            plugin = telescope-nvim;
            config = ''
              nnoremap  ,fg  :execute 'Telescope git_files cwd=' . expand('%:p:h')<cr>
              nnoremap  ,ff  <cmd>lua require('telescope.builtin').find_files()<cr>
              nnoremap  ,f/  <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>
              nnoremap  ,fb  <cmd>lua require('telescope.builtin').buffers()<cr>
              nnoremap  ,fo  <cmd>lua require('telescope.builtin').file_browser()<cr>
              nnoremap  ,fh  <cmd>lua require('telescope.builtin').oldfiles()<cr>
              nnoremap  ,fc  <cmd>lua require('telescope.builtin').colorscheme()<cr>
              nnoremap  ,fr  <cmd>lua require('telescope.builtin').registers()<cr>
            '';
          }

          # https://github.com/akinsho/toggleterm.nvim
          #   "A neovim plugin to persist and toggle multiple terminals during an editing session"
          {
            plugin = toggleterm-nvim;
            config = ''
              lua << EOF
              require("toggleterm").setup{
                direction = 'float',
                winblend = 3,
                float_opts = {border = 'curved'}
              }
              EOF
              nnoremap <silent> <c-\>      <cmd>execute 'ToggleTerm dir=' . expand('%:p:h')<cr>
              inoremap <silent> <c-\> <esc><cmd>execute 'ToggleTerm dir=' . expand('%:p:h')<cr>
              tnoremap <silent> <c-\> <esc><cmd>ToggleTerm<cr>
            '';
          }

          # https://github.com/mhartington/formatter.nvim
          #   "A format runner for neovim, written in lua"
          {
            plugin = formatter-nvim;
            config = ''
              lua << EOF
              require('formatter').setup({logging = true,filetype = {
                sh = {
                  function()
                  return {ignore_exitcode = true, exe ="${pkgs.shfmt}/bin/shfmt ", stdin = true, args = {"-ci","-i 2","-"}}
                  end
                },
                nix = {
                  function()
                  return {ignore_exitcode = true, exe = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt",stdin = true}
                  end
                },
                hcl = {
                  function()
                  return {ignore_exitcode = true, exe = "${pkgs.packer}/bin/packer",stdin = true,args = {"fmt","-"}}
                  end
                },
                terraform = {
                  function()
                  return {ignore_exitcode = true, exe = "${pkgs.terraform}/bin/terraform",stdin = true,args = {"fmt","-"}}
                  end
                },
                yaml = {
                  function()
                  return {ignore_exitcode = true, exe = "${pkgs.yamlfix}/bin/yamlfix",stdin = true,args = {"-"}}
                  end
                },
              }})
              EOF

              nnoremap <silent> ,f :Format<CR>
              nnoremap <silent> ,F :FormatWrite<CR>
            '';
          }

          # https://github.com/f-person/git-blame.nvim
          #   "A git blame plugin for Neovim written in Lua"
          {
            plugin = git-blame-nvim;
            config = ''
              let g:gitblame_enabled = 0
              nnoremap  ,,b  :GitBlameToggle<cr>
            '';
          }

          # https://github.com/lewis6991/gitsigns.nvim
          #   "Super fast git decorations implemented purely in lua/teal"
          {
            plugin = gitsigns-nvim;
            config = ''
              lua require('gitsigns').setup()
              set signcolumn=yes " always show gutter
            '';
          }

          # https://github.com/hoob3rt/lualine.nvim
          #   "A blazing fast and easy to configure neovim statusline written in pure lua"
          {
            plugin = lualine-nvim;
            config = ''
              lua << EOF
              require('lualine').setup {
                options = {
                  section_separators = " ",
                  component_separators = " "
                }
              }
              EOF
            '';
          }

          # https://github.com/hrsh7th/nvim-cmp
          #   "A completion plugin for neovim coded in Lua"
          #cmp-emoji
          #cmp-path
          #cmp-spell
          #cmp-buffer
          #cmp-treesitter
          #{
          #  plugin = nvim-cmp;
          #  config = ''
          #    set completeopt=menu,menuone,noselect

          #    lua << EOF
          #    local cmp = require'cmp'
          #    cmp.setup({
          #    sources = cmp.config.sources({
          #      -- { name = 'nvim_lsp' },
          #      -- { name = 'vsnip' }, -- For vsnip users.
          #      -- { name = 'luasnip' }, -- For luasnip users.
          #      -- { name = 'ultisnips' }, -- For ultisnips users.
          #      -- { name = 'snippy' }, -- For snippy users.
          #    }, {
          #      { name = 'buffer' },
          #    }),
          #    window = {
          #          completion = cmp.config.window.bordered(),
          #          documentation = cmp.config.window.bordered(),
          #        },
          #      -- suuuources = {
          #      --   -- { name = 'emoji'},
          #      --   -- { name = 'path'},
          #      --   -- { name = 'spell' },
          #      --   { name = 'buffer' },
          #      --   { name = 'treesitter' },
          #      -- },
          #      -- -- mapping = {
          #      -- --   ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item()),
          #      -- -- }
          #    })
          #    EOF

          #    nnoremap <silent> ,,f :Format<cr>
          #  '';
          #}

          # https://github.com/folke/which-key.nvim
          #   "displays a popup with possible keybindings of the command you started typing"
          {
            plugin = which-key-nvim;
            config = "lua require('which-key').setup()";
          }

          # https://github.com/tjdevries/train.nvim
          #   "Train yourself with vim motions and make your own train tracks :)"
          {
            plugin = train-nvim;
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
            config = "lua require('numb').setup()";
          }

          # ------------------------------------ Vimscript Plugins ---------------------------------------------

          # https://github.com/farmergreg/vim-lastplace
          #   "Intelligently reopen files at your last edit position in Vim"
          vim-lastplace

          # https://github.com/dhruvasagar/vim-table-mode
          #   "VIM Table Mode for instant [ASCII] table creation"
          {
            plugin = vim-table-mode;
            config = ''
              " Make tables github markdown compatable
              let g:table_mode_corner='|'
              nnoremap  <silent>  ,,a   :TableModeToggle<cr>
            '';
          }
        ];

      extraConfig = ''
        " shortmess: I: don't give the intro message when starting Vim |:intro|
        set shortmess=I

        set clipboard=unnamedplus

        imap jj <Esc>

        " Hard mode
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

        " avoid using :
        nnoremap  <silent>  <leader>qq  :q!<cr>
        nnoremap  <silent>  <leader>ww  :w<cr>
        nnoremap  <silent>  <leader>wq  :wq<cr>

        " keep terminal in background
        set hidden

        " set title in Kitty term tab to just the filename
        set titlestring=%t
        set title

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

        "set conceallevel=2

        " cant spell
        set spell
        set spelllang=en
      '';
    };
  };
}
