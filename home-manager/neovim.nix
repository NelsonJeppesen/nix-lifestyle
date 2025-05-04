# neovim: my cozy home for code and configuration
{ pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      withNodeJs = true;

      # install LSPs/linters/formatters
      extraPackages = [
        # bash
        pkgs.bash-language-server
        pkgs.shfmt

        # nix
        pkgs.nixd
        pkgs.nixfmt-rfc-style

        # php
        pkgs.phpactor

        # python
        pkgs.python312Packages.python-lsp-server

        # ruby
        pkgs.ruby-lsp

        # terraform
        pkgs.terraform
        pkgs.terraform-ls
        pkgs.tflint

        # misc
        pkgs.typos-lsp
        pkgs.yaml-language-server
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

        vim.opt.clipboard   = 'unnamedplus'
        vim.opt.expandtab   = true
        vim.opt.ignorecase  = true
        vim.opt.shiftwidth  = 2
        vim.opt.smartcase   = true
        vim.opt.softtabstop = 2
        vim.opt.swapfile    = false
        vim.opt.undofile    = true
      '';

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins = with pkgs.vimPlugins; [
        # misc deps
        dressing-nvim
        nui-nvim
        plenary-nvim

        # "A fancy, configurable, notification manager for NeoVim"
        # https://github.com/rcarriga/nvim-notify
        {
          plugin = nvim-notify;
          type = "lua";
          config = "vim.notify = require('notify')";
        }

        # "💥 Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu"
        # https://github.com/folke/noice.nvim/
        {
          plugin = noice-nvim;
          type = "lua";
          config = ''
            require("noice").setup({})
          '';
        }

        # "displays a popup with possible keybindings of the command you started typing"
        #   https://github.com/folke/which-key.nvim
        {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
            local wk = require("which-key")
             require("which-key").setup {
               win = {
                 border = "rounded",
                 padding = { 1, 2, 1, 2 },
               },
             }

             wk.add({
               { "<leader><space>",  desc = "Smart Find Files",  function() Snacks.picker.smart() end },
               { "<leader>,",  desc = "Buffers",                 function() Snacks.picker.buffers() end },
               { "<leader>/",  desc = "Grep",                    function() Snacks.picker.grep() end },
               { "<leader>:",  desc = "Command History",         function() Snacks.picker.command_history() end },
               { "<leader>n",  desc = "Notification History",    function() Snacks.picker.notifications() end },
               { "<leader>e",  desc = "File Explorer",           function() Snacks.explorer() end },

               { "<leader>q", group = "Quit" },
               { "<leader>qq", desc = "Quit",                    "<cmd>q<cr>" },
               { "<leader>qf", desc = "Quit [force]",            "<cmd>q!<cr>" },

               { "<leader>w", group = "Write" },
               { "<leader>wq", desc = "Write Quit",              "<cmd>wq<cr>" },
               { "<leader>ww", desc = "Write",                   "<cmd>w<cr>" },

               { "<leader>a", group = "Avante" },

               { "<leader>l", group = "LSP" },
               { "<leader>li", desc = "LSP Info",                "<cmd>LspInfo<cr>"},
               { "<leader>lD", desc = "Goto Declaration",        function() Snacks.picker.lsp_declarations() end},
               { "<leader>lI", desc = "Goto Implementation",     function() Snacks.picker.lsp_implementations() end},
               { "<leader>ld", desc = "Goto Definition",         function() Snacks.picker.lsp_definitions() end},
               { "<leader>lf", desc = "Format Document",         function() vim.lsp.buf.format() end},
               { "<leader>lr", desc = "References",              function() Snacks.picker.lsp_references() end, nowait = true},
               { "<leader>ly", desc = "Goto T[y]pe Definition",  function() Snacks.picker.lsp_type_definitions() end},
               { "<leader>ls", desc = "LSP Symbols",             function() Snacks.picker.lsp_symbols() end},
               { "<leader>lS", desc = "LSP Workspace Symbols",   function() Snacks.picker.lsp_workspace_symbols() end},

               { "<leader>f", group = "Find" },
               { "<leader>fb", desc = "Buffers",                 function() Snacks.picker.buffers() end },
               { "<leader>fc", desc = "Find Config File",        function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
               { "<leader>ff", desc = "Find Files",              function() Snacks.picker.files() end },
               { "<leader>fg", desc = "Find Git Files",          function() Snacks.picker.git_files() end },
               { "<leader>fp", desc = "Projects",                function() Snacks.picker.projects() end },
               { "<leader>fr", desc = "Recent",                  function() Snacks.picker.recent() end },

               { "<leader>g", group = "Git" },
               { "<leader>gb", desc = "Git Branches",            function() Snacks.picker.git_branches() end },
               { "<leader>gl", desc = "Git Log",                 function() Snacks.picker.git_log() end },
               { "<leader>gL", desc = "Git Log Line",            function() Snacks.picker.git_log_line() end },
               { "<leader>gs", desc = "Git Status",              function() Snacks.picker.git_status() end },
               { "<leader>gS", desc = "Git Stash",               function() Snacks.picker.git_stash() end },
               { "<leader>gd", desc = "Git Diff (Hunks)",        function() Snacks.picker.git_diff() end },
               { "<leader>gf", desc = "Git Log File",            function() Snacks.picker.git_log_file() end },

               { "<leader>s", group = "Search/Grep" },
               { "<leader>sb", desc = "Buffer Lines",            function() Snacks.picker.lines() end },
               { "<leader>sB", desc = "Grep Open Buffers",       function() Snacks.picker.grep_buffers() end },
               { "<leader>sg", desc = "Grep",                    function() Snacks.picker.grep() end },
               { "<leader>sw", desc = "Visual selection",        function() Snacks.picker.grep_word() end, mode = { "n", "x" }},
               { '<leader>s"', desc = "Registers",               function() Snacks.picker.registers() end },
               { '<leader>s/', desc = "Search History",          function() Snacks.picker.search_history() end },
               { "<leader>sa", desc = "Autocmds",                function() Snacks.picker.autocmds() end },
               { "<leader>sb", desc = "Buffer Lines",            function() Snacks.picker.lines() end },
               { "<leader>sc", desc = "Command History",         function() Snacks.picker.command_history() end },
               { "<leader>sC", desc = "Commands",                function() Snacks.picker.commands() end },
               { "<leader>sd", desc = "Diagnostics",             function() Snacks.picker.diagnostics() end },
               { "<leader>sD", desc = "Buffer Diagnostics",      function() Snacks.picker.diagnostics_buffer() end },
               { "<leader>sh", desc = "Help Pages",              function() Snacks.picker.help() end },
               { "<leader>sH", desc = "Highlights",              function() Snacks.picker.highlights() end },
               { "<leader>si", desc = "Icons",                   function() Snacks.picker.icons() end },
               { "<leader>sj", desc = "Jumps",                   function() Snacks.picker.jumps() end },
               { "<leader>sk", desc = "Keymaps",                 function() Snacks.picker.keymaps() end },
               { "<leader>sl", desc = "Location List",           function() Snacks.picker.loclist() end },
               { "<leader>sm", desc = "Marks",                   function() Snacks.picker.marks() end },
               { "<leader>sM", desc = "Man Pages",               function() Snacks.picker.man() end },
               { "<leader>sp", desc = "Search for Plugin Spec",  function() Snacks.picker.lazy() end },
               { "<leader>sq", desc = "Quickfix List",           function() Snacks.picker.qflist() end },
               { "<leader>sR", desc = "Resume",                  function() Snacks.picker.resume() end },
               { "<leader>su", desc = "Undo History",            function() Snacks.picker.undo() end },

               { "<leader>u", group = "Util" },
               { "<leader>uc", desc = "Copy Buffer",             "<cmd>%y+<cr>"},
               { "<leader>ub", desc = "Decode Base64",           "<cmd>%!base64 -d<cr>"},
               { "<leader>ug", desc = "Decode Base64-gzip",      "<cmd>%!base64 -d|gzip -d<cr>"},
               { "<leader>uj", desc = "Format JSON",             "<cmd>%!jq .<cr>"},
               { "<leader>uC", desc = "Colorschemes",            function() Snacks.picker.colorschemes() end },

               { "<leader>ut", desc = "Table Mode: Toggle",      "<cmd>TableModeToggle<cr>"},
               { "<leader>ur", desc = "Table Mode: Realign",     "<cmd>TableModeRealign<cr>"},
             })
          '';
        }

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

        {
          plugin = copilot-lua;
          type = "lua";
          config = ''
            require("copilot").setup({
              suggestion = { enabled = false },
              panel = { enabled = false },
              filetypes = {
                markdown = true,
                help = true,
              },
            })
          '';
        }

        {
          plugin = blink-copilot;
          type = "lua";
          config = '''';
        }

        # fuzzy picker
        {
          plugin = snacks-nvim;
          type = "lua";
          config = "require('snacks').setup()";
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

        # "Use your Neovim like using Cursor AI IDE! "
        #   https://github.com/yetone/avante.nvim
        {
          plugin = avante-nvim;
          type = "lua";
          config = ''require("avante").setup({provider = "openai"})'';
        }

        # "Performant, batteries-included completion plugin for Neovim"
        # https://github.com/Saghen/blink.cmp?tab=readme-ov-file
        blink-cmp-avante
        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require("blink.cmp").setup({
              sources = {
                default = { 'avante', 'copilot', 'lsp', 'path', 'snippets', 'buffer' },
                providers = {
                  avante = {
                    async = true,
                    module = 'blink-cmp-avante',
                    name = 'avante',
                    score_offset = 75,
                  },
                  copilot = {
                    async = true,
                    module = "blink-copilot",
                    name = "copilot",
                    score_offset = 100,
                  },
                }
              },
              keymap = {
                ['<C-y>'] = {  },
                ['<C-a>'] = { 'select_and_accept' },
              },
              completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 100 },
                ghost_text = { enabled = true },
              },
              signature = {
                enabled = true,
                window = {border = "rounded"},
              },
            })
          '';
        }
        # "A clean, dark Neovim theme written in Lua, with support for lsp, treesitter
        # and lots of plugins. Includes additional themes for Kitty, Alacritty, iTerm and Fish"
        # https://github.com/folke/tokyonight.nvim/?tab=readme-ov-file
        {
          plugin = tokyonight-nvim;
          type = "viml";

          # set theme very early so other plugins can pull in the settings e.g. bufferline
          config = ''
            set bg=dark

            " set color-scheme on gnome light/dark setting
            let theme=system('dconf read /org/gnome/desktop/interface/color-scheme')

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
          config = "require('neoscroll').setup({})";
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
          config = "require('highlight-undo').setup({duration = 500})";
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
          type = "lua";
          config = "require('gitsigns').setup()";
        }

        # "A blazing fast and easy to configure neovim statusline written in pure lua"
        #   https://github.com/hoob3rt/lualine.nvim
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup {
              options = {
                theme = 'papercolor_light',
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
        { plugin = numb-nvim; }

        {
          plugin = vim-illuminate;
          type = "lua";
          config = "";
        }

        ## ------------------------------------ Vimscript Plugins ---------------------------------------------

        ## "Intelligently reopen files at your last edit position in Vim"
        ##   https://github.com/farmergreg/vim-lastplace
        vim-lastplace

        # "VIM Table Mode for instant [ASCII] table creation"
        #   https://github.com/dhruvasagar/vim-table-mode
        {
          plugin = vim-table-mode;
          type = "lua";
          config = ''
            -- use which-key
            vim.g.table_mode_disable_mappings = 1
            vim.g.table_mode_disable_tableize_mappings = 1

            -- GitHub markdown
            vim.g.table_mode_corner='|'
          '';
        }
      ];

      extraConfig = ''
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
      '';
    };
  };
}
