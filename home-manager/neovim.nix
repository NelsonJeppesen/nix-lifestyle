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
        vim.opt.foldenable  = false  -- Disable folding entirely.

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

        # mini.ai: extended a/i text objects (arguments, function calls, etc.)
        # Adds: a/i a (argument), a/i f (function call), a/i o (block/cond/loop),
        # a/i q (quote), a/i b (bracket), a/i ? (user prompt), and more.
        # https://github.com/echasnovski/mini.ai
        {
          plugin = mini-ai;
          type = "lua";
          config = ''
            local ai = require("mini.ai")
            ai.setup({
              n_lines = 500,
              custom_textobjects = {
                o = ai.gen_spec.treesitter({
                  a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                  i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                }),
                f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
                c = ai.gen_spec.treesitter({ a = "@class.outer",    i = "@class.inner" }),
              },
            })
          '';
        }

        # nvim-various-textobjs: extra text objects (indent, value, key, url, etc.)
        # Notable: ii/ai indent, iv/av value (after =/:), ik/ak key, iS/aS subword,
        # gc inside comment, gG entire buffer, !/!! diagnostic, im/am chain member.
        # https://github.com/chrisgrieser/nvim-various-textobjs
        {
          plugin = nvim-various-textobjs;
          type = "lua";
          config = ''
            require("various-textobjs").setup({
              keymaps = { useDefaults = true },
            })
          '';
        }

        # nvim-autopairs: treesitter-aware auto-pair for brackets, quotes, etc.
        # Smarter than mini.pairs: skips pairing inside strings/comments and
        # when the cursor is adjacent to word characters (no apostrophe woes).
        # https://github.com/windwp/nvim-autopairs
        {
          plugin = nvim-autopairs;
          type = "lua";
          config = ''
            require("nvim-autopairs").setup({
              check_ts = true, -- use treesitter to decide context
              ts_config = {
                lua  = { "string" },        -- don't pair inside lua strings
                javascript = { "template_string" },
              },
              fast_wrap = {                  -- <M-e> to wrap next obj in pair
                map = "<M-e>",
                chars = { "{", "[", "(", '"', "'" },
                end_key = "$",
                keys = "qwertyuiopzxcvbnmasdfghjkl",
                check_comma = true,
                highlight = "Search",
                highlight_grey = "Comment",
              },
            })
          '';
        }

        # flash.nvim removed: was unused (s key bound to mini.surround).

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
          config = builtins.readFile ./neovim/lua/which-key-nvim.lua;
        }

        # nvim-lspconfig: configuration for built-in LSP client
        # Enables language servers that are installed via extraPackages above
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            -- Diagnostics: tiny-inline-diagnostic.nvim renders the message; we
            -- disable the built-in virtual_text/virtual_lines to avoid double
            -- display.
            vim.diagnostic.config({ virtual_text = false, virtual_lines = false })

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
        # Nixpkgs ships the rewritten `main` branch where the legacy
        # `nvim-treesitter.configs` module no longer exists. Highlight, indent
        # and folds are now driven directly by Neovim's built-in tree-sitter
        # APIs (`:h treesitter`); we just enable them via FileType autocmds.
        # Parsers come bundled via withAllGrammars (no install needed).
        #   https://github.com/nvim-treesitter/nvim-treesitter/tree/main
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = ''
            -- Enable highlight + indent for any filetype that has a
            -- registered parser. pcall guards against filetypes whose parser
            -- isn't bundled (treesitter raises on unknown languages).
            -- Folding intentionally disabled.
            vim.api.nvim_create_autocmd("FileType", {
              callback = function(args)
                local lang = vim.treesitter.language.get_lang(args.match)
                if not lang or not vim.treesitter.language.add(lang) then return end
                pcall(vim.treesitter.start, args.buf, lang)
                vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
              end,
            })
          '';
        }

        # nvim-treesitter-textobjects: select / move by syntactic objects
        # The `main` branch exposes setup() for global options; keymaps are
        # set explicitly per object (no more nested `keymaps` table).
        {
          plugin = nvim-treesitter-textobjects;
          type = "lua";
          config = ''
            require("nvim-treesitter-textobjects").setup({
              select = { lookahead = true },
              move   = { set_jumps = true },
            })

            local sel  = function(q) return function() require("nvim-treesitter-textobjects.select").select_textobject(q, "textobjects") end end
            local nxts = function(q) return function() require("nvim-treesitter-textobjects.move").goto_next_start(q, "textobjects") end end
            local nxte = function(q) return function() require("nvim-treesitter-textobjects.move").goto_next_end(q,   "textobjects") end end
            local prvs = function(q) return function() require("nvim-treesitter-textobjects.move").goto_previous_start(q, "textobjects") end end
            local prve = function(q) return function() require("nvim-treesitter-textobjects.move").goto_previous_end(q,   "textobjects") end end

            -- Selection (operator + visual)
            for lhs, q in pairs({
              ["af"] = "@function.outer", ["if"] = "@function.inner",
              ["ac"] = "@class.outer",    ["ic"] = "@class.inner",
              ["ab"] = "@block.outer",    ["ib"] = "@block.inner",
              ["aa"] = "@parameter.outer",["ia"] = "@parameter.inner",
              ["ai"] = "@conditional.outer",["ii"] = "@conditional.inner",
              ["al"] = "@loop.outer",     ["il"] = "@loop.inner",
            }) do vim.keymap.set({ "x", "o" }, lhs, sel(q)) end

            -- Movement (next / previous, start / end)
            for lhs, q in pairs({
              ["]f"] = "@function.outer", ["]c"] = "@class.outer",
              ["]b"] = "@block.outer",    ["]p"] = "@parameter.inner",
              ["]i"] = "@conditional.outer", ["]o"] = "@loop.outer",
              ["]m"] = "@call.outer",
            }) do vim.keymap.set({ "n", "x", "o" }, lhs, nxts(q)) end
            for lhs, q in pairs({
              ["]B"] = "@block.inner",    ["]I"] = "@conditional.inner",
              ["]M"] = "@call.inner",     ["]O"] = "@loop.inner",
            }) do vim.keymap.set({ "n", "x", "o" }, lhs, nxte(q)) end
            for lhs, q in pairs({
              ["[f"] = "@function.outer", ["[c"] = "@class.outer",
              ["[b"] = "@block.outer",    ["[p"] = "@parameter.inner",
              ["[i"] = "@conditional.outer", ["[o"] = "@loop.outer",
              ["[m"] = "@call.outer",
            }) do vim.keymap.set({ "n", "x", "o" }, lhs, prvs(q)) end
            for lhs, q in pairs({
              ["[B"] = "@block.inner",    ["[I"] = "@conditional.inner",
              ["[M"] = "@call.inner",     ["[O"] = "@loop.inner",
            }) do vim.keymap.set({ "n", "x", "o" }, lhs, prve(q)) end
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

        # neoscroll-nvim → replaced by mini-animate (covers cursor, scroll,
        # window open/close/resize in one consistent system).

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

        # tiny-glimmer.nvim: smooth animations for yank, paste, undo/redo, search.
        # Replaces highlight-undo.nvim (it was the inspiration) and provides one
        # consistent animation system across all edit operations.
        # https://github.com/rachartier/tiny-glimmer.nvim
        {
          plugin = tiny-glimmer-nvim;
          type = "lua";
          config = ''
            require("tiny-glimmer").setup({
              overwrite = {
                auto_map = true,
                yank   = { enabled = true,  default_animation = "fade" },
                paste  = { enabled = true,  default_animation = "reverse_fade" },
                search = { enabled = true,  default_animation = "pulse" },
                undo   = { enabled = true,  default_animation = {
                  name = "fade",
                  settings = { from_color = "DiffDelete", max_duration = 500, min_duration = 500 },
                }},
                redo   = { enabled = true,  default_animation = {
                  name = "fade",
                  settings = { from_color = "DiffAdd",    max_duration = 500, min_duration = 500 },
                }},
              },
              hijack_ft_disabled = { "snacks_dashboard", "oil" },
            })
          '';
        }

        # tiny-inline-diagnostic.nvim: prettier inline LSP diagnostics with
        # arrows pointing to the offending column. Replaces the built-in
        # virtual_text/virtual_lines display (disabled in nvim-lspconfig above).
        # https://github.com/rachartier/tiny-inline-diagnostic.nvim
        {
          plugin = tiny-inline-diagnostic-nvim;
          type = "lua";
          config = ''
            require("tiny-inline-diagnostic").setup({
              preset = "modern",
              options = {
                show_source = { enabled = true, if_many = true },
                multilines  = { enabled = true, always_show = false },
                show_all_diags_on_cursorline = false,
                enable_on_insert = false,
              },
            })
          '';
        }

        # tiny-devicons-auto-colors.nvim: auto-tints mini-icons / devicons to
        # match the active colorscheme palette. Re-applies on ColorScheme so it
        # follows the GNOME day/night switching configured below.
        # https://github.com/rachartier/tiny-devicons-auto-colors.nvim
        {
          plugin = tiny-devicons-auto-colors-nvim;
          type = "lua";
          config = ''
            local function apply_devicon_colors()
              local ok, colors = pcall(function()
                return require("tokyonight.colors").setup()
              end)
              if not ok then return end
              require("tiny-devicons-auto-colors").setup({ colors = colors })
            end
            apply_devicon_colors()
            vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_devicon_colors })
          '';
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

        # headhunter.nvim: navigate and resolve git merge conflicts in-buffer
        # Defaults clash with our <leader>g* git pickers, so remap to <leader>gm*
        # (m for "merge"). Conflict navigation uses ]g/[g (no clash).
        # https://github.com/StackInTheWild/headhunter.nvim
        {
          plugin = headhunter-nvim;
          type = "lua";
          config = ''
            require("headhunter").setup({
              keys = {
                prev        = "[g",
                next        = "]g",
                take_head   = "<leader>gmh",
                take_origin = "<leader>gmo",
                take_both   = "<leader>gmb",
                quickfix    = "<leader>gmq",
              },
            })
          '';
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

        # mini.animate: animate cursor moves, scrolling, and window open/close/
        # resize. Replaces neoscroll.nvim with a unified animation system.
        # https://github.com/echasnovski/mini.animate
        {
          plugin = mini-animate;
          type = "lua";
          config = ''
            local animate = require("mini.animate")
            animate.setup({
              cursor = { enable = false }, -- handled by smear-cursor.nvim
              scroll = { enable = true, timing = animate.gen_timing.linear({ duration = 120, unit = "total" }) },
              resize = { enable = true, timing = animate.gen_timing.linear({ duration = 100, unit = "total" }) },
              open   = { enable = false }, -- avoid conflicts with noice/snacks pickers
              close  = { enable = false },
            })
          '';
        }

        # smear-cursor.nvim: leave a fading "smear" trail when the cursor jumps.
        # Pure cosmetic; pairs with mini.animate's cursor animation.
        # https://github.com/sphamba/smear-cursor.nvim
        {
          plugin = smear-cursor-nvim;
          type = "lua";
          config = ''
            require("smear_cursor").setup({
              smear_between_buffers = true,
              smear_between_neighbor_lines = true,
              stiffness = 0.7,
              trailing_stiffness = 0.5,
              hide_target_hack = false,
            })
          '';
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
