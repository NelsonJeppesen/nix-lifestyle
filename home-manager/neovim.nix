# neovim: my cozy home for code and configuration
{ pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      withNodeJs = true;

      extraPackages = [
        pkgs.bash-language-server
        pkgs.nixd
        pkgs.phpactor
        pkgs.ruby-lsp
        pkgs.terraform-ls
        pkgs.tflint
        pkgs.typos-lsp
        pkgs.yaml-language-server
        pkgs.python312Packages.python-lsp-server
      ];

      # extraPython3Packages = pyPkgs: with pyPkgs; [ python-lsp-server ];

      extraLuaConfig = ''
        -- map leader to <Space>
        vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
        vim.g.mapleader = " "

        -- unmap esc to retrain myself on jj
        vim.keymap.set("i", "<Esc>", "<Nop>", { noremap = true, silent = true })

        -- set persistent undo history between neovim sessions
        local undodir = vim.fn.stdpath("cache") .. "/undo"

        if vim.fn.isdirectory(undodir) == 0 then
          vim.fn.mkdir(undodir, "p", '0o700')
        end

        vim.o.undodir     = undodir
        vim.o.undofile    = true
        vim.o.swapfile    = false
        vim.o.ignorecase  = true
        vim.o.smartcase   = true
      '';

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins = with pkgs.vimPlugins; [
        mini-icons
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            vim.diagnostic.config({ virtual_lines = { current_line = true }})

            -- https://github.com/neovim/nvim-lspconfig/tree/master/lsp
            vim.lsp.enable('bashls')
            vim.lsp.enable('nixd')
            vim.lsp.enable('phpactor')
            vim.lsp.enable('pylsp')
            vim.lsp.enable('ruby_lsp')
            vim.lsp.enable('terraformls')
            vim.lsp.enable('tflint')
            vim.lsp.enable('typos_lsp')
            vim.lsp.enable('yamlls')

            -- vim.lsp.enable('jsonls') missing vscode-json-language-server
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
              { "<leader>l",  group = "LSP" },
              { "<leader>li", desc = "LSP Info",                "<cmd>LspInfo<cr>"},
              { "<leader>lD", desc = "Goto Declaration",        function() Snacks.picker.lsp_declarations() end},
              { "<leader>lI", desc = "Goto Implementation",     function() Snacks.picker.lsp_implementations() end},
              { "<leader>ld", desc = "Goto Definition",         function() Snacks.picker.lsp_definitions() end},
              { "<leader>lf", desc = "Format Document",         function() vim.lsp.buf.format() end},
              { "<leader>lr", desc = "References",              function() Snacks.picker.lsp_references() end, nowait = true},
              { "<leader>ly", desc = "Goto T[y]pe Definition",  function() Snacks.picker.lsp_type_definitions() end},
              { "<leader>ls", desc = "LSP Symbols",             function() Snacks.picker.lsp_symbols() end},
              { "<leader>lS", desc = "LSP Workspace Symbols",   function() Snacks.picker.lsp_workspace_symbols() end},

              { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
              { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
              { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
              { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
              { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
              { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },

              { "<leader>f",  group = "Find" },
              { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
              { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
              { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
              { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
              { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
              { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },

              { "<leader>g",  group = "Git" },
              { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
              { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
              { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
              { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
              { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
              { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
              { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },

              { "<leader>s",  group = "Grep" },
              { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
              { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
              { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
              { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
              { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
              { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
              { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
              { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
              { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
              { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
              { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
              { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
              { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
              { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
              { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
              { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
              { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
              { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
              { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
              { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
              { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
              { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
              { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
              { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo History" },

              { "<leader>u",  group = "Util" },
              { "<leader>uc", desc = "Copy Buffer",         "<cmd>%y+<cr>"},
              { "<leader>ub", desc = "Decode Base64",       "<cmd>%!base64 -d<cr>"},
              { "<leader>ug", desc = "Decode Base64-gzip",  "<cmd>%!base64 -d|gzip -d<cr>"},
              { "<leader>uj", desc = "Format JSON",         "<cmd>%!jq .<cr>"},
              { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" },
            })
          '';
        }

        # fuzzy picker
        snacks-nvim

        {
          plugin = flash-nvim;
          type = "lua";
          config = ''
          '';
        }

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

        # "Performant, batteries-included completion plugin for Neovim"
        # https://github.com/Saghen/blink.cmp?tab=readme-ov-file
        friendly-snippets
        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require("blink.cmp").setup({
              -- keymap = { preset = 'super-tab' },
              completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 100 },
                ghost_text = { enabled = true },
                menu = {
                  draw = {
                    columns = {
                      { "label", "label_description", gap = 1 },
                      { "kind_icon", "kind" }
                    },
                  }
                }
              },
              signature = {
                enabled = true,
                window = {
                	border = "rounded",
                },
              },
            })
          '';
        }

        # "Use your Neovim like using Cursor AI IDE! "
        #   https://github.com/yetone/avante.nvim
        {
          plugin = avante-nvim;
          type = "lua";
          config = ''require("avante").setup({provider = "openai"})'';
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
            "let theme=system('dconf read /org/gnome/desktop/interface/color-scheme')

            "if theme =~ "default"
              colorscheme tokyonight-moon
            "else
            "  colorscheme tokyonight-night
            "end
          '';
        }

        # "Smooth scrolling neovim plugin written in lua "
        #   https://github.com/karb94/neoscroll.nvim/
        {
          plugin = neoscroll-nvim;
          type = "lua";
          config = ''require('neoscroll').setup({})'';
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
          config = ''require('highlight-undo').setup({duration = 500})'';
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

        {
          plugin = mini-indentscope;
          type = "lua";
          config = "require('mini.indentscope').setup()";
        }

        # "Peek lines just when you intend"
        #   https://github.com/nacro90/numb.nvim/
        {
          plugin = numb-nvim;
        }

        {
          plugin = vim-illuminate;
          type = "lua";
          config = '''';
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
        inoremap <Down>   <Nop>
        inoremap <Left>   <Nop>
        inoremap <Right>  <Nop>
        inoremap <Up>     <Nop>

        " Remove newbie crutches in Normal Mode
        nnoremap <Down>   <Nop>
        nnoremap <Left>   <Nop>
        nnoremap <Right>  <Nop>
        nnoremap <Up>     <Nop>

        " Remove newbie crutches in Visual Mode
        vnoremap <Down>   <Nop>
        vnoremap <Left>   <Nop>
        vnoremap <Right>  <Nop>
        vnoremap <Up>     <Nop>

        "" Indentation settings for using 2 spaces instead of tabs.
        set shiftwidth=2
        set softtabstop=2
        set expandtab

        set list listchars=tab:→\ ,
      '';
    };
  };
}
