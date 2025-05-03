# neovim: my cozy home for code and configuration
{ pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;

      extraPackages = [
        pkgs.bash-language-server
        pkgs.nixd
        pkgs.ruby-lsp
        pkgs.terraform-ls
        pkgs.tflint
        pkgs.typos-lsp
        pkgs.yaml-language-server
      ];

      extraLuaConfig = ''
        -- map leader to <Space>
        vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
        vim.g.mapleader = " "

        -- unmap esc to retrain myself on jj
        vim.keymap.set("i", "<Esc>", "<Nop>", { noremap = true, silent = true })
      '';

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            vim.diagnostic.config({ virtual_lines = { current_line = true }})

            -- https://github.com/neovim/nvim-lspconfig/tree/master/lsp
            -- vim.lsp.enable('jsonls') missing vscode-json-language-server
            vim.lsp.enable('bashls')
            vim.lsp.enable('nixd')
            vim.lsp.enable('ruby_lsp')
            vim.lsp.enable('terraformls')
            vim.lsp.enable('tflint')
            vim.lsp.enable('typos_lsp')
            vim.lsp.enable('yamlls')
          '';
        }

        ## "displays a popup with possible keybindings of the command you started typing"
        ##   https://github.com/folke/which-key.nvim
        {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
            local wk = require("which-key")

             wk.add({
              { "<leader>l", group = "LSP" },
              { "<leader>lf",function() vim.lsp.buf.format() end,desc = "Format Document"},
            })
          '';
        }

        # fuzzy picker
        snacks-nvim

        # Install tree-sitter with all the plugins/grammars
        #   https://tree-sitter.github.io/tree-sitter
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            require'nvim-treesitter.configs'.setup({
              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false
              }
            })
          '';
        }

        # "map keys without delay when typing "
        # https://github.com/max397574/better-escape.nvim/
        {
          plugin = better-escape-nvim;
          type = "lua";
          config = ''require("better_escape").setup()'';
        }

        #{
        #  plugin = nvim-navic;
        #  type = "lua";
        #  config = ''
        #    require("nvim-navic")
        #  '';
        #}

        # "Performant, batteries-included completion plugin for Neovim"
        # https://github.com/Saghen/blink.cmp?tab=readme-ov-file
        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require("blink.cmp").setup({
            	-- https://cmp.saghen.dev/configuration/fuzzy.html
              keymap = { preset = 'super-tab' },

            	-- https://cmp.saghen.dev/configuration/signature.html
            	signature = {
            		enabled = true,
            		window = {
            			border = "rounded",
            		},
            	},
            })
          '';
        }

        # "null-ls.nvim reloaded / Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua."
        # https://github.com/nvimtools/none-ls.nvim/tree/main
        # using git until nixpkgs moves to new repo
        # {
        #  plugin = (
        #    pkgs.vimUtils.buildVimPlugin {
        #      name = "none-ls.nvim";
        #      src = pkgs.fetchFromGitHub {
        #        owner = "nvimtools";
        #        repo = "none-ls.nvim";
        #        rev = "master"; # or a commit hash or tag
        #        sha256 = "sha256-Yg3VpsXhdbz195BHfZ2P+nfn5yrgyXbxjoOPrLvSJnQ="; # may 2, 2025
        #      };
        #    }
        #  );

        # "Neovim plugin to manage the file system and other tree like structures"
        #   https://github.com/nvim-neo-tree/neo-tree.nvim/
        {
          plugin = neo-tree-nvim;
          type = "lua";
          config = ''
            require('neo-tree').setup({
              filesystem = {
                commands = {
                  avante_add_files = function(state)
                    local node = state.tree:get_node()
                    local filepath = node:get_id()
                    local relative_path = require('avante.utils').relative_path(filepath)

                    local sidebar = require('avante').get()

                    local open = sidebar:is_open()
                    -- ensure avante sidebar is open
                    if not open then
                      require('avante.api').ask()
                      sidebar = require('avante').get()
                    end

                    sidebar.file_selector:add_selected_file(relative_path)

                    -- remove neo tree buffer
                    if not open then
                      sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
                    end
                  end,
                },
                window = {
                  mappings = {
                    ['oa'] = 'avante_add_files',
                  },
                },
              },
            })

            vim.keymap.set("n", "<leader>e", "<Cmd>Neotree reveal<CR>")
            vim.keymap.set("n", "<leader>E", "<Cmd>Neotree toggle<CR>")
          '';
        }

        # "Use your Neovim like using Cursor AI IDE! "
        #   https://github.com/yetone/avante.nvim
        {
          plugin = avante-nvim;
          type = "lua";
          config = ''
            require("avante").setup({
              provider = "openai",
            })
          '';
        }

        # "🏙 A clean, dark Neovim theme written in Lua, with support for lsp, treesitter
        # and lots of plugins. Includes additional themes for Kitty, Alacritty, iTerm and Fish"
        # https://github.com/folke/tokyonight.nvim/?tab=readme-ov-file
        {
          plugin = tokyonight-nvim;
          type = "viml";

          # set theme very early so other plugins can pull in the settings e.g. bufferline
          config = ''
            " set color-scheme on gnome light/dark setting
            "
            " read gnome light/dark setting
            let theme=system('dconf read /org/gnome/desktop/interface/color-scheme')

            " set vim color scheme
            if theme =~ "default"
              colorscheme tokyonight-moon
            else
              colorscheme tokyonight-night
            end
          '';
        }

        # "Smooth scrolling neovim plugin written in lua "
        #   https://github.com/karb94/neoscroll.nvim/
        {
          plugin = neoscroll-nvim;
          type = "lua";
          config = ''
            require('neoscroll').setup({})
          '';
        }

        # https://github.com/iamcco/markdown-preview.nvim/
        #   "markdown preview plugin for (neo)vim"
        markdown-preview-nvim

        # https://github.com/akinsho/bufferline.nvim
        #  "A snazzy bufferline for Neovim"
        {
          plugin = bufferline-nvim;
          type = "viml";
          config = ''
            lua <<EOF
              require("bufferline").setup{
                options={
                  max_name_length=38,
                  max_prefix_length=35,
                  separator_style='slope',
                  show_buffer_close_icons=false,
                  show_buffer_icons=false,
                  show_close_icon=false,
                }
              }
            EOF
            nnoremap <silent> <C-h>  :BufferLineCyclePrev<CR>
            nnoremap <silent> <C-l>  :BufferLineCycleNext<CR>
            nnoremap <silent> <C-j>  <C-w>w
            nnoremap <silent> <C-k>  <C-w>w
            nnoremap <silent> <C-left>  :BufferLineCyclePrev<CR>
            nnoremap <silent> <C-right> :BufferLineCycleNext<CR>
            nnoremap <silent> <C-up>    <C-w>w
            nnoremap <silent> <C-down>  <C-w>w
          '';
        }

        # "Highlight changed text after Undo / Redo operations"
        #   https://github.com/tzachar/highlight-undo.nvim/
        {
          plugin = highlight-undo-nvim;
          type = "lua";
          config = ''require('highlight-undo').setup({duration = 2000})'';
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
            nnoremap <silent> <c-\>     <cmd>execute 'ToggleTerm direction=float      dir=' . expand('%:p:h')<CR>
            nnoremap <silent> <S-c-\>   <cmd>execute 'ToggleTerm direction=horizontal dir=' . expand('%:p:h')<CR>
            inoremap <silent> <c-\>     <esc><cmd>execute 'ToggleTerm dir=' . expand('%:p:h')<CR>
            tnoremap <silent> <c-\>     <esc><cmd>ToggleTerm<CR>
            tnoremap <silent> <S-c-\>   <esc><cmd>ToggleTerm<CR>
          '';
        }

        # "Super fast git decorations implemented purely in lua/teal"
        #   https://github.com/lewis6991/gitsigns.nvim
        {
          plugin = gitsigns-nvim;
          type = "viml";
          config = "lua require('gitsigns').setup()";
        }

        # "A blazing fast and easy to configure neovim statusline written in pure lua"
        #   https://github.com/hoob3rt/lualine.nvim
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

        # "Peek lines just when you intend"
        #   https://github.com/nacro90/numb.nvim/
        {
          plugin = numb-nvim;
        }

        ## ------------------------------------ Vimscript Plugins ---------------------------------------------

        ## "Intelligently reopen files at your last edit position in Vim"
        ##   https://github.com/farmergreg/vim-lastplace
        vim-lastplace

        # "VIM Table Mode for instant [ASCII] table creation"
        #   https://github.com/dhruvasagar/vim-table-mode
        {
          plugin = vim-table-mode;
          type = "viml";
          config = "let g:table_mode_corner='|' "; # GitHub markdown
        }
      ];

      extraConfig = ''
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

        "nnoremap <leader>bc  :%y+<CR>
        "nnoremap <leader>bb  :%!base64 -d<CR>
        "nnoremap <leader>bg  :%!base64 -d\|gzip -d<CR>
        "nnoremap <leader>bj  :%!jq .<CR>
        "nnoremap <leader>by  :%!yq -y .<CR>

        "nnoremap <leader>q :q!<CR>

        " persistent undo
        if !isdirectory($HOME."/.config/nvim/undo")
            call mkdir($HOME."/.config/nvim/undo", "", 0700)
        endif
        set undodir=~/.config/nvim/undo

        "" Indentation settings for using 2 spaces instead of tabs.
        set shiftwidth=2
        set softtabstop=2
        set expandtab

        set list listchars=tab:→\ ,

        "" disable swp
        set noswapfile
      '';

    };
  };
}
