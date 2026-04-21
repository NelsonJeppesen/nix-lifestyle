# neovim.nix - Neovim editor configuration
#
# Full-featured Neovim setup with:
# - LSP servers for bash, nix, PHP, Python, Ruby, Terraform, YAML, and typos
# - 30+ plugins including completion (blink.cmp + Copilot), fuzzy finding (snacks),
#   syntax highlighting (treesitter), file management (oil.nvim), and AI integration
# - TokyoNight colorscheme with auto dark/light detection from GNOME settings
# - Which-key for discoverable keybindings organized by leader key groups
# - Arrow keys disabled to encourage proper vim motions (hardtime + precognition)
# - OpenCode AI assistant integration via opencode.nvim
{ pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      defaultEditor = true; # Set as $EDITOR and $VISUAL
      vimAlias = true; # Create `vim` alias pointing to nvim
      withNodeJs = true; # Enable Node.js provider (needed by some plugins)

      # LSP servers, linters, and formatters installed alongside neovim
      # These are added to neovim's PATH so nvim-lspconfig can find them
      extraPackages = [
        # Bash
        pkgs.bash-language-server # LSP for shell scripts
        pkgs.shfmt # Shell formatter (also used by bash-language-server)

        # Nix
        pkgs.nixd # Nix language server (better than nil for nixpkgs)
        pkgs.nixfmt # Nix formatter (RFC style)

        # PHP
        pkgs.phpactor # PHP language server

        # Python
        pkgs.python313Packages.python-lsp-server # Python LSP

        # Ruby
        pkgs.ruby-lsp # Ruby language server

        # Terraform
        pkgs.terraform # Needed by terraform-ls for validation
        pkgs.terraform-ls # Official Terraform language server
        pkgs.tflint # Terraform linter

        # Misc
        pkgs.typos-lsp # Spellcheck-like LSP for source code typos
        pkgs.vscode-langservers-extracted # JSON / HTML / CSS / ESLint LSPs
        pkgs.yaml-language-server # YAML LSP with JSON schema support
      ];

      # extraPython3Packages = pyPkgs: with pyPkgs; [ python-lsp-server ];

      # Lua configuration that runs before plugins load
      initLua = ''
        -- Enable 24-bit RGB color in the TUI (required by colorizer and themes)
        vim.opt.termguicolors = true

        -- Editor defaults: 2-space indentation, no swap files
        vim.opt.expandtab   = true
        vim.opt.shiftwidth  = 2
        vim.opt.softtabstop = 2
        vim.opt.swapfile    = false
        vim.opt.showmode    = false  -- Disable mode display for statusline plugins.

        -- Limit LSP log to errors only (prevents lsp.log from growing to GBs)
        vim.lsp.log.set_level("ERROR")

        -- Configure LSP/diagnostic icons (Nerd Font symbols)
        vim.diagnostic.config({
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = "",
              [vim.diagnostic.severity.WARN]  = "",
              [vim.diagnostic.severity.INFO]  = "",
              [vim.diagnostic.severity.HINT]  = "󰌵",
            },
          },
          virtual_text   = false,
          underline      = true,
          update_in_insert = false,
        })

        -- opencode.nvim configuration (set early for plugin init)
        vim.o.autoread = true
        vim.g.opencode_opts = {}

        -- Disable arrow keys to encourage proper vim motions.
        for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
          vim.keymap.set({ "i", "v" }, key, "<Nop>", { silent = true })
          vim.keymap.set("n", key,
            ':echo "Arrow keys are disabled!"<CR>',
            { silent = true })
        end
      '';

      # ── Plugin configuration ────────────────────────────────────────
      # Plugins are managed by home-manager via nixpkgs vimPlugins.
      # Each plugin entry can specify type ("lua" or "viml") and inline config.
      plugins = with pkgs.vimPlugins; [

        # Fun: cellular automaton animation (:CellularAutomaton make_it_rain)
        cellular-automaton-nvim

        # mini.basics: sensible defaults for options, mappings, and autocommands
        # Part of the mini.nvim library by echasnovski
        #   https://github.com/echasnovski/mini.basics
        {
          plugin = mini-basics;
          type = "lua";
          config = ''
            require("mini.basics").setup({
              options = {
                basic = true,
                extra_ui = true,
              },
              mappings = {
                basic = true,
                windows = true,
                move_with_alt = true,
              },
            })
          '';
        }

        # mini.surround: add/delete/replace surrounding delimiters (quotes, brackets)
        # sa = add, sd = delete, sr = replace (followed by delimiter char)
        # https://github.com/echasnovski/mini.surround
        {
          plugin = mini-surround;
          type = "lua";
          config = ''require("mini.surround").setup()'';
        }

        # mini.pairs: auto-close brackets, quotes, and parentheses
        # https://github.com/echasnovski/mini.pairs
        {
          plugin = mini-pairs;
          type = "lua";
          config = ''require("mini.pairs").setup()'';
        }

        # flash.nvim: label-based jump motions (press s then type target chars)
        # By the same author as snacks/noice; faster than repeated w/f/search
        # https://github.com/folke/flash.nvim
        {
          plugin = flash-nvim;
          type = "lua";
          config = ''require("flash").setup()'';
        }

        # treewalker.nvim: move around code in a syntax-tree-aware manner
        # Ctrl+hjkl navigates between AST nodes, Ctrl+Shift+jk swaps nodes
        #   https://github.com/aaronik/treewalker.nvim/
        {
          plugin = treewalker-nvim;
          type = "lua";
          config = ''
            require('treewalker').setup({})

            -- movement (Alt+hjkl; Ctrl+hjkl is reserved for window navigation
            -- via mini.basics mappings.windows = true)
            vim.keymap.set({ 'n', 'v' }, '<M-k>', '<cmd>Treewalker Up<cr>',    { silent = true, desc = "Treewalker Up" })
            vim.keymap.set({ 'n', 'v' }, '<M-j>', '<cmd>Treewalker Down<cr>',  { silent = true, desc = "Treewalker Down" })
            vim.keymap.set({ 'n', 'v' }, '<M-h>', '<cmd>Treewalker Left<cr>',  { silent = true, desc = "Treewalker Left" })
            vim.keymap.set({ 'n', 'v' }, '<M-l>', '<cmd>Treewalker Right<cr>', { silent = true, desc = "Treewalker Right" })

            -- swapping
            vim.keymap.set('n', '<M-S-k>', '<cmd>Treewalker SwapUp<cr>',   { silent = true, desc = "Treewalker SwapUp" })
            vim.keymap.set('n', '<M-S-j>', '<cmd>Treewalker SwapDown<cr>', { silent = true, desc = "Treewalker SwapDown" })
          '';
        }

        # nvim-colorizer: display color codes as their actual color inline
        {
          plugin = nvim-colorizer-lua;
          type = "lua";
          config = ''require("colorizer").setup({})'';
        }

        # oil.nvim: file explorer that lets you edit the filesystem like a buffer
        # Includes git status integration via oil-git-status-nvim
        oil-git-status-nvim
        {
          plugin = oil-nvim;
          type = "lua";
          config = ''
            require("oil").setup({
              win_options = {
                signcolumn = "yes:2",
              },
            })
            require("oil-git-status").setup()
          '';
        }

        # precognition.nvim: show available vim motions as virtual text hints
        # Starts hidden; toggle with <leader>q, peek with q
        # https://github.com/tris203/precognition.nvim
        {
          plugin = precognition-nvim;
          type = "lua";
          config = ''require("precognition").setup({startVisible = false})'';
        }

        # hardtime.nvim: break bad habits by limiting repetitive key presses
        # Encourages using proper vim motions instead of hjkl spam
        #   https://github.com/m4xshen/hardtime.nvim
        {
          plugin = hardtime-nvim;
          type = "lua";
          config = ''require("hardtime").setup()'';
        }

        # ── Common plugin dependencies ────────────────────────────────
        mini-icons # Icon provider for various plugins
        nui-nvim # UI component library
        plenary-nvim # Lua utility functions (used by many plugins)
        render-markdown-nvim # Render markdown with formatting in buffers

        # fidget.nvim: lightweight LSP progress indicator (bottom-right corner)
        # Replaces noice LSP progress with a less intrusive display
        # https://github.com/j-hui/fidget.nvim
        {
          plugin = fidget-nvim;
          type = "lua";
          config = ''require("fidget").setup({})'';
        }

        # noice.nvim: modern command line UI replacement
        # Popups, notifications, and LSP messages are disabled per user preference
        #   https://github.com/folke/noice.nvim/
        {
          plugin = noice-nvim;
          type = "lua";
          config = ''
            require("noice").setup({
              cmdline = { enabled = true },
              messages = { enabled = false },
              notify = { enabled = false },
              popupmenu = { enabled = false },
              lsp = {
                progress = { enabled = false },
                hover = { enabled = false },
                signature = { enabled = false },
                message = { enabled = false },
              },
            })
          '';
        }

        # which-key.nvim: displays available keybindings in a popup as you type
        # All leader key groups and their mappings are defined here
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
                 no_overlap = false,
               },
               triggers = {
                 { "<auto>", mode = "nxsot" },
                 { "s", mode = { "n", "x" } },
               },
            }

            wk.add({
              -- Quick access bindings
              { 'q', desc = "precognition peek", function() require("precognition").peek() end},
              { '<c-\\>', desc = "Toggle Terminal", function() require("toggleterm").toggle() end, mode = { "n", "i", "t" } },

              { "<leader>fml", desc = "FML" ,"<cmd>CellularAutomaton make_it_rain<cr>"},

              -- Top-level leader shortcuts
              { "<leader><space>", desc = "Smart Find Files", function() Snacks.picker.smart() end },
              { "<leader>,", desc = "Buffers", function() Snacks.picker.buffers() end },
              { "<leader>/", desc = "Grep", function() Snacks.picker.grep() end },
              { "<leader>:", desc = "Command History", function() Snacks.picker.command_history() end },
              { "<leader>n", desc = "Notification History", function() Snacks.picker.notifications() end },
              { "<leader>e", desc = "Oil", "<cmd>Oil<cr>" },
              { "<leader>?", desc = "keybindings", function() require("which-key").show() end },

              -- Quit group
              { "<leader>q", group = "Quit" },
              { "<leader>qq", desc = "Quit", "<cmd>q<cr>" },
              { "<leader>qa", desc = "Quit All", "<cmd>qa<cr>" },
              { "<leader>qf", desc = "Quit [force]", "<cmd>qa!<cr>" },

              -- Write group
              { "<leader>w", group = "Write" },
              { "<leader>wq", desc = "Write Quit", "<cmd>wq<cr>" },
              { "<leader>ww", desc = "Write", "<cmd>w<cr>" },

              -- OpenCode AI integration group
              { "<leader>o", group = "OpenCode" },

              -- Diagnostics group (trouble.nvim)
              { "<leader>x", group = "Diagnostics" },
              { "<leader>xx", desc = "Diagnostics (Trouble)", "<cmd>Trouble diagnostics toggle<cr>" },
              { "<leader>xX", desc = "Buffer Diagnostics", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>" },
              { "<leader>xs", desc = "Symbols (Trouble)", "<cmd>Trouble symbols toggle focus=false<cr>" },
              { "<leader>xl", desc = "Location List", "<cmd>Trouble loclist toggle<cr>" },
              { "<leader>xq", desc = "Quickfix List", "<cmd>Trouble qflist toggle<cr>" },
              { "<leader>xt", desc = "Todo Comments", "<cmd>Trouble todo toggle<cr>" },

              -- LSP group: language server interactions
              { "<leader>l", group = "LSP" },
              { "<leader>li", desc = "LSP Info", "<cmd>LspInfo<cr>" },
              { "<leader>lD", desc = "Goto Declaration", function() Snacks.picker.lsp_declarations() end },
              { "<leader>lI", desc = "Goto Implementation", function() Snacks.picker.lsp_implementations() end },
              { "<leader>ld", desc = "Goto Definition", function() Snacks.picker.lsp_definitions() end },
              -- <leader>lf is registered by conform.nvim (formatter with LSP fallback)
              { "<leader>lr", desc = "References", function() Snacks.picker.lsp_references() end, nowait = true },
              { "<leader>ly", desc = "Goto T[y]pe Definition", function() Snacks.picker.lsp_type_definitions() end },
              { "<leader>ls", desc = "LSP Symbols", function() Snacks.picker.lsp_symbols() end },
              { "<leader>lS", desc = "LSP Workspace Symbols", function() Snacks.picker.lsp_workspace_symbols() end },

              -- Find group: file and buffer navigation
              { "<leader>f", group = "Find" },
              { "<leader>fb", desc = "Buffers", function() Snacks.picker.buffers() end },
              { "<leader>fc", desc = "Find Config File", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
              { "<leader>ff", desc = "Find Files", function() Snacks.picker.files() end },
              { "<leader>fg", desc = "Find Git Files", function() Snacks.picker.git_files() end },
              { "<leader>fp", desc = "Projects", function() Snacks.picker.projects() end },
              { "<leader>fr", desc = "Recent", function() Snacks.picker.recent() end },

              -- Git group: git operations via snacks picker
              { "<leader>g", group = "Git" },
              { "<leader>gb", desc = "Git Branches", function() Snacks.picker.git_branches() end },
              { "<leader>gl", desc = "Git Log", function() Snacks.picker.git_log() end },
              { "<leader>gL", desc = "Git Log Line", function() Snacks.picker.git_log_line() end },
              { "<leader>gs", desc = "Git Status", function() Snacks.picker.git_status() end },
              { "<leader>gS", desc = "Git Stash", function() Snacks.picker.git_stash() end },
              { "<leader>gd", desc = "Git Diff (Hunks)", function() Snacks.picker.git_diff() end },
              { "<leader>gf", desc = "Git Log File", function() Snacks.picker.git_log_file() end },
              { "<leader>gD", desc = "Diffview Open", "<cmd>DiffviewOpen<cr>" },
              { "<leader>gc", desc = "Diffview Close", "<cmd>DiffviewClose<cr>" },
              { "<leader>gh", desc = "Diffview File History", "<cmd>DiffviewFileHistory %<cr>" },

              -- Search/Grep group: content search and exploration
              { "<leader>s", group = "Search/Grep" },
              { "<leader>sb", desc = "Buffer Lines", function() Snacks.picker.lines() end },
              { "<leader>sB", desc = "Grep Open Buffers", function() Snacks.picker.grep_buffers() end },
              { "<leader>sg", desc = "Grep", function() Snacks.picker.grep() end },
              { "<leader>sw", desc = "Visual selection", function() Snacks.picker.grep_word() end, mode = { "n", "x" } },
              { '<leader>s"', desc = "Registers", function() Snacks.picker.registers() end },
              { '<leader>s/', desc = "Search History", function() Snacks.picker.search_history() end },
              { "<leader>sa", desc = "Autocmds", function() Snacks.picker.autocmds() end },
              { "<leader>sc", desc = "Command History", function() Snacks.picker.command_history() end },
              { "<leader>sC", desc = "Commands", function() Snacks.picker.commands() end },
              { "<leader>sd", desc = "Diagnostics", function() Snacks.picker.diagnostics() end },
              { "<leader>sD", desc = "Buffer Diagnostics", function() Snacks.picker.diagnostics_buffer() end },
              { "<leader>sh", desc = "Help Pages", function() Snacks.picker.help() end },
              { "<leader>sH", desc = "Highlights", function() Snacks.picker.highlights() end },
              { "<leader>si", desc = "Icons", function() Snacks.picker.icons() end },
              { "<leader>sj", desc = "Jumps", function() Snacks.picker.jumps() end },
              { "<leader>sk", desc = "Keymaps", function() Snacks.picker.keymaps() end },
              { "<leader>sl", desc = "Location List", function() Snacks.picker.loclist() end },
              { "<leader>sm", desc = "Marks", function() Snacks.picker.marks() end },
              { "<leader>sM", desc = "Man Pages", function() Snacks.picker.man() end },
              { "<leader>sp", desc = "Search for Plugin Spec", function() Snacks.picker.lazy() end },
              { "<leader>sq", desc = "Quickfix List", function() Snacks.picker.qflist() end },
              { "<leader>sR", desc = "Resume", function() Snacks.picker.resume() end },
              { "<leader>su", desc = "Undo History", function() Snacks.picker.undo() end },

              -- Util group: buffer operations and formatting
              { "<leader>u", group = "Util" },
              { "<leader>uc", desc = "Copy Buffer", "<cmd>%y+<cr>" },
              { "<leader>ub", desc = "Decode Base64", "<cmd>%!base64 -d<cr>" },
              { "<leader>ug", desc = "Decode Base64-gzip", "<cmd>%!base64 -d|gzip -d<cr>" },
              { "<leader>uj", desc = "Format JSON", "<cmd>%!jq .<cr>" },
              { "<leader>uC", desc = "Colorschemes", function() Snacks.picker.colorschemes() end },
              { "<leader>up", desc = "Precognition Toggle", function() require("precognition").toggle() end },

              { "<leader>ut", desc = "Table Mode: Toggle", "<cmd>TableModeToggle<cr>" },
              { "<leader>ur", desc = "Table Mode: Realign", "<cmd>TableModeRealign<cr>" },

              -- Textobject navigation (treesitter-textobjects)
              { "[", group = "Previous" },
              { "[B", desc = "Previous Block Inner" },
              { "[I", desc = "Previous Conditional Inner" },
              { "[M", desc = "Previous Call Inner" },
              { "[O", desc = "Previous Loop Inner" },
              { "[S", desc = "Previous Scope Inner" },
              { "[b", desc = "Previous Block Outer" },
              { "[c", desc = "Previous Class Outer" },
              { "[f", desc = "Previous Function Outer" },
              { "[i", desc = "Previous Conditional Outer" },
              { "[m", desc = "Previous Call Outer" },
              { "[o", desc = "Previous Loop Outer" },
              { "[p", desc = "Previous Parameter Inner" },
              { "[s", desc = "Previous Scope Outer" },

              { "]", group = "Next" },
              { "]B", desc = "Next Block Inner" },
              { "]I", desc = "Next Conditional Inner" },
              { "]M", desc = "Next Call Inner" },
              { "]O", desc = "Next Loop Inner" },
              { "]S", desc = "Next Scope Inner" },
              { "]b", desc = "Next Block Outer" },
              { "]c", desc = "Next Class Outer" },
              { "]f", desc = "Next Function Outer" },
              { "]i", desc = "Next Conditional Outer" },
              { "]m", desc = "Next Call Outer" },
              { "]o", desc = "Next Loop Outer" },
              { "]p", desc = "Next Parameter Inner" },
              { "]s", desc = "Next Scope Outer" },

              -- Surround (mini.surround)
              { "s",  group = "Surround" },
              { "sa", desc = "Add Surrounding", mode = { "n", "v" } },
              { "sd", desc = "Delete Surrounding" },
              { "sf", desc = "Find Right" },
              { "sF", desc = "Find Left" },
              { "sh", desc = "Highlight Surrounding" },
              { "sn", desc = "Update n_lines" },
              { "sr", desc = "Replace Surrounding" },

              -- Toggle options (mini.basics)
              { "\\",  group = "Toggle" },
              { "\\b", desc = "Background" },
              { "\\c", desc = "Cursorline" },
              { "\\C", desc = "Cursorcolumn" },
              { "\\d", desc = "Diagnostics" },
              { "\\h", desc = "Inlay Hints" },
              { "\\i", desc = "Ignorecase" },
              { "\\l", desc = "List" },
              { "\\n", desc = "Number" },
              { "\\r", desc = "Relativenumber" },
              { "\\s", desc = "Spell" },
              { "\\w", desc = "Wrap" },

              -- Goto prefix
              { "g",   group = "Goto" },
              { "go",  desc = "Add Empty Line Below" },
              { "gO",  desc = "Add Empty Line Above" },

              -- LSP defaults (Neovim 0.11+)
              { "gr",  group = "LSP (builtin)" },
              { "grn", desc = "Rename" },
              { "gra", desc = "Code Action", mode = { "n", "v" } },
              { "grr", desc = "References" },
              { "gri", desc = "Implementation" },

              -- Todo comment navigation
              { "]t", desc = "Next Todo Comment" },
              { "[t", desc = "Previous Todo Comment" },

              -- Misc implicit bindings
              { "K",     desc = "Hover Documentation" },
              { "<C-s>", desc = "Save", mode = { "n", "i", "x" } },
            })
          '';
        }

        # nvim-lspconfig: configuration for built-in LSP client
        # Enables language servers that are installed via extraPackages above
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            -- Show diagnostics inline for the current line only
            vim.diagnostic.config({ virtual_lines = { current_line = true }})

            -- Enable all configured language servers
            -- https://github.com/neovim/nvim-lspconfig/tree/master/lsp
            vim.lsp.enable('bashls')
            vim.lsp.enable('jsonls')
            vim.lsp.enable('nixd')
            vim.lsp.enable('phpactor')
            vim.lsp.enable('pylsp')
            vim.lsp.enable('ruby_lsp')
            vim.lsp.enable('terraformls')
            vim.lsp.enable('typos_lsp')
            vim.lsp.enable('yamlls')

            -- NOTE: tflint is a linter, not an LSP; run via nvim-lint or CLI.
          '';
        }

        # Treesitter textobjects: navigate and select code by semantic units
        nvim-treesitter-textobjects

        # trouble.nvim: structured diagnostics list with filtering and preview
        # https://github.com/folke/trouble.nvim
        {
          plugin = trouble-nvim;
          type = "lua";
          config = ''require("trouble").setup({})'';
        }

        # todo-comments.nvim: highlight TODO/FIXME/HACK/NOTE in code
        # Integrates with Trouble for searchable todo list
        # https://github.com/folke/todo-comments.nvim
        {
          plugin = todo-comments-nvim;
          type = "lua";
          config = ''require("todo-comments").setup({})'';
        }

        # conform.nvim: formatter engine with per-filetype configuration
        # Formatters (nixfmt, shfmt) are in extraPackages; use <leader>lf to format
        # https://github.com/stevearc/conform.nvim
        {
          plugin = conform-nvim;
          type = "lua";
          config = ''
            require("conform").setup({
              formatters_by_ft = {
                nix = { "nixfmt" },
                sh = { "shfmt" },
                bash = { "shfmt" },
              },
            })
            -- Override <leader>lf to use conform with LSP fallback
            vim.keymap.set("n", "<leader>lf", function()
              require("conform").format({ async = true, lsp_format = "fallback" })
            end, { desc = "Format Document" })
          '';
        }

        # blink-copilot: Copilot source for blink.cmp completion
        # https://github.com/fang2hou/blink-copilot
        blink-copilot

        # snacks.nvim: collection of QoL plugins (picker, explorer, terminal, etc.)
        # Only a few modules are enabled; the rest are explicitly disabled
        # https://github.com/folke/snacks.nvim
        {
          plugin = snacks-nvim;
          type = "lua";
          config = ''
            require('snacks').setup({
                picker = { enabled = true},
                explorer = { enabled = true},
                terminal = { enabled = true},

                statuscolumn = { enabled = false},
                bigfile = { enabled = false },
                dashboard = { enabled = false },
                indent = { enabled = false },
                input = { enabled = false },
                notifier = { enabled = false },
                quickfile = { enabled = false },
                scope = { enabled = false },
                scroll = { enabled = false },
                words = { enabled = false },
            })
          '';
        }

        # nvim-treesitter: syntax highlighting and code parsing via tree-sitter
        # Installs all available grammars for maximum language coverage.
        # Calling `configs.setup{}` is required on the master branch (which is
        # what nixpkgs ships) to suppress the legacy-API deprecation notice;
        # parsers come bundled via withAllGrammars (no install needed).
        #   https://tree-sitter.github.io/tree-sitter
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            require("nvim-treesitter.configs").setup({
              -- parsers are provided by withAllGrammars; never install at runtime
              ensure_installed = {},
              auto_install = false,
              sync_install = false,
              ignore_install = {},
              modules = {},

              highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
              },
              indent = { enable = true },

              -- nvim-treesitter-textobjects (selection + movement + swap)
              textobjects = {
                select = {
                  enable = true,
                  lookahead = true,
                  keymaps = {
                    ["af"] = "@function.outer", ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
                    ["ab"] = "@block.outer",    ["ib"] = "@block.inner",
                    ["aa"] = "@parameter.outer",["ia"] = "@parameter.inner",
                    ["ai"] = "@conditional.outer",["ii"] = "@conditional.inner",
                    ["al"] = "@loop.outer",     ["il"] = "@loop.inner",
                  },
                },
                move = {
                  enable = true,
                  set_jumps = true,
                  goto_next_start = {
                    ["]f"] = "@function.outer", ["]c"] = "@class.outer",
                    ["]b"] = "@block.outer",    ["]p"] = "@parameter.inner",
                    ["]i"] = "@conditional.outer", ["]o"] = "@loop.outer",
                    ["]m"] = "@call.outer",     ["]s"] = "@scope",
                  },
                  goto_next_end = {
                    ["]B"] = "@block.inner",    ["]I"] = "@conditional.inner",
                    ["]M"] = "@call.inner",     ["]O"] = "@loop.inner",
                    ["]S"] = "@scope",
                  },
                  goto_previous_start = {
                    ["[f"] = "@function.outer", ["[c"] = "@class.outer",
                    ["[b"] = "@block.outer",    ["[p"] = "@parameter.inner",
                    ["[i"] = "@conditional.outer", ["[o"] = "@loop.outer",
                    ["[m"] = "@call.outer",     ["[s"] = "@scope",
                  },
                  goto_previous_end = {
                    ["[B"] = "@block.inner",    ["[I"] = "@conditional.inner",
                    ["[M"] = "@call.inner",     ["[O"] = "@loop.inner",
                    ["[S"] = "@scope",
                  },
                },
              },
            })
          '';
        }

        # opencode.nvim: OpenCode AI assistant integration for Neovim
        # Provides keybindings to ask questions, toggle UI, and execute actions
        # https://github.com/NickvanDyke/opencode.nvim
        {
          plugin = opencode-nvim;
          type = "lua";
          config = ''
            -- opencode keybindings (set after plugin loads)
            vim.keymap.set({ "n", "x" }, "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
            vim.keymap.set({ "n", "x" }, "<leader>ox", function() require("opencode").select() end, { desc = "Execute opencode action" })
            vim.keymap.set({ "n", "x" }, "<leader>op", function() require("opencode").prompt("@this") end, { desc = "Add to opencode prompt" })
            vim.keymap.set({ "n", "t" }, "<leader>og", function() require("opencode").toggle() end, { desc = "Toggle opencode" })
            vim.keymap.set("n", "<leader>os", function() require("opencode").command("session.half.page.up") end, { desc = "Scroll up" })
            vim.keymap.set("n", "<leader>od", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll down" })
            vim.keymap.set("n", "<leader>oc", function() require("opencode").stop() end, { desc = "Stop opencode" })
          '';
        }

        # copilot.lua: GitHub Copilot integration for Neovim
        # Required by blink-copilot for completion source
        # https://github.com/zbirenbaum/copilot.lua
        {
          plugin = copilot-lua;
          type = "lua";
          config = ''
            require("copilot").setup({
              suggestion = { enabled = false },
              panel = { enabled = false },
              filetypes = { markdown = true, help = true },
            })
          '';
        }

        # blink.cmp: fast, batteries-included completion engine
        # Sources: Copilot (highest priority), LSP, path, snippets, buffer
        # https://github.com/Saghen/blink.cmp
        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require("blink.cmp").setup({
              sources = {
                default = { 'copilot', 'lsp', 'path', 'snippets', 'buffer' },
                providers = {
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

        # tokyonight.nvim: dark/light colorscheme with wide plugin support
        # Auto-detects GNOME dark/light preference and switches accordingly
        # https://github.com/folke/tokyonight.nvim
        {
          plugin = tokyonight-nvim;
          type = "lua";
          config = ''
            local function apply_theming()
              local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
              local result = handle and handle:read("*l") or ""
              if handle then handle:close() end
              if result:find("prefer%-dark") then
                vim.cmd("colorscheme tokyonight-night")
              else
                vim.cmd("colorscheme tokyonight-day")
              end
              vim.o.background = "dark"
            end
            -- Re-apply on focus to detect system theme changes
            vim.api.nvim_create_autocmd({ "VimEnter", "FocusGained" }, { callback = apply_theming })
            apply_theming()
          '';
        }

        # neoscroll.nvim: smooth scrolling animations
        # https://github.com/karb94/neoscroll.nvim/
        {
          plugin = neoscroll-nvim;
          type = "lua";
          config = "require('neoscroll').setup({})";
        }

        # markdown-preview.nvim: live markdown preview in browser
        # https://github.com/iamcco/markdown-preview.nvim/
        markdown-preview-nvim

        # bufferline.nvim: tab-like buffer line at the top of the editor
        # https://github.com/akinsho/bufferline.nvim
        {
          plugin = bufferline-nvim;
          type = "lua";
          config = ''
            require("bufferline").setup{
              options = {
                max_name_length = 38,
                max_prefix_length = 35,
                separator_style = 'thick',
                show_buffer_close_icons = false,
                show_buffer_icons = false,
                show_close_icon = false,
              }
            }
          '';
        }

        # highlight-undo.nvim: briefly highlight changed text after undo/redo
        # https://github.com/tzachar/highlight-undo.nvim/
        {
          plugin = highlight-undo-nvim;
          type = "lua";
          config = "require('highlight-undo').setup({duration = 500})";
        }

        # toggleterm.nvim: floating terminal overlay (Ctrl+\\ to toggle)
        # https://github.com/akinsho/toggleterm.nvim
        {
          plugin = toggleterm-nvim;
          type = "lua";
          config = ''
            require("toggleterm").setup{
              direction = 'float',
              winblend = 3,
              float_opts = {border = 'curved'}
            }
          '';
        }

        # gitsigns.nvim: git decorations in the sign column (added/modified/deleted)
        # https://github.com/lewis6991/gitsigns.nvim
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = "require('gitsigns').setup()";
        }

        # diffview.nvim: tabpage git diff/merge viewer with file tree
        # Open with <leader>gD, close with <leader>gc, file history with <leader>gh
        # https://github.com/sindrets/diffview.nvim
        diffview-nvim

        # nvim-navic: breadcrumb navigation in the winbar showing current code context
        # Auto-attaches to LSP servers that support documentSymbols
        # https://github.com/SmiteshP/nvim-navic
        {
          plugin = nvim-navic;
          type = "lua";
          config = ''
            require("nvim-navic").setup({
              lsp = { auto_attach = true },
              click = true,
            })

            -- Set winbar only on buffers where navic actually attached, so
            -- non-LSP buffers don't show stale/empty breadcrumbs.
            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.server_capabilities.documentSymbolProvider then
                  vim.wo.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
                end
              end,
            })
          '';
        }

        # lualine.nvim: fast statusline written in Lua
        # Uses auto theme detection to match the active colorscheme
        # https://github.com/hoob3rt/lualine.nvim
        {
          plugin = lualine-nvim;
          type = "lua";
          config = ''
            require('lualine').setup {
              options = {
                theme = 'auto',
                section_separators = " ",
                component_separators = " "
              },
            }
          '';
        }

        # mini.indentscope: animated indent guides showing current scope
        # https://github.com/echasnovski/mini.indentscope
        {
          plugin = mini-indentscope;
          type = "lua";
          config = "require('mini.indentscope').setup()";
        }

        # numb.nvim: peek lines when typing :<number> (before pressing Enter)
        # https://github.com/nacro90/numb.nvim/
        {
          plugin = numb-nvim;
          type = "lua";
          config = "require('numb').setup()";
        }

        # vim-illuminate: highlight other uses of the word under cursor
        # Uses LSP, treesitter, or regex matching automatically
        # https://github.com/RRethy/vim-illuminate
        vim-illuminate

        ## ───────────────────── Vimscript Plugins ─────────────────────

        # vim-lastplace: reopen files at the last edit position
        # https://github.com/farmergreg/vim-lastplace
        vim-lastplace

        # vim-table-mode: instant ASCII table creation and formatting
        # Toggle with <leader>ut, realign with <leader>ur
        # https://github.com/dhruvasagar/vim-table-mode
        {
          plugin = vim-table-mode;
          type = "lua";
          config = ''
            -- Disable default mappings (using which-key instead)
            vim.g.table_mode_disable_mappings = 1
            vim.g.table_mode_disable_tableize_mappings = 1
            vim.g.table_mode_corner='|'
            vim.g.table_mode_header_fillchar='-'
          '';
        }
      ];

      # Vimscript configuration (runs after plugins). Arrow-key disabling has
      # been moved to initLua (vim.keymap.set form) — this block is reserved
      # for the few options that don't have first-class Lua equivalents.
      extraConfig = ''
        set background=dark
        set relativenumber
      '';
    };
  };
}
