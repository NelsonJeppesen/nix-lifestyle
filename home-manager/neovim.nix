# neovim: my cozy home for code and configuration
{ pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins = with pkgs.vimPlugins; [

        # fuzzy picker
        snacks-nvim

        # deps
        #plenary-nvim

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

        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = ''
            vim.diagnostic.config({ virtual_lines = { current_line = true }})

            -- https://github.com/neovim/nvim-lspconfig/tree/master/lsp
            vim.lsp.enable('terraformls')
            vim.lsp.enable('nixd')
            vim.lsp.enable('jsonls')
            vim.lsp.enable('yamlls')
          '';
        }

        {
          plugin = nvim-navic;
          type = "lua";
          config = ''
            require("nvim-navic")
          '';
        }

        {
          plugin = blink-cmp;
          type = "lua";
          config = ''
            require("blink.cmp").setup({
            	-- https://cmp.saghen.dev/configuration/fuzzy.html
            	fuzzy = { implementation = "rust" },

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

        #  type = "lua";

        #  config = ''
        #    local null_ls = require("null-ls")

        #    null_ls.setup({
        #      sources = {
        #        --null_ls.builtins.formatting.nixftm,
        #        --null_ls.builtins.formatting.terraform_fmt,
        #      },
        #    })
        #  '';
        #}

        # "Neovim plugin to manage the file system and other tree like structures"
        #   https://github.com/nvim-neo-tree/neo-tree.nvim/
        #{
        #  plugin = neo-tree-nvim;
        #  type = "lua";
        #  config = ''
        #    require('neo-tree').setup({
        #      filesystem = {
        #        commands = {
        #          avante_add_files = function(state)
        #            local node = state.tree:get_node()
        #            local filepath = node:get_id()
        #            local relative_path = require('avante.utils').relative_path(filepath)

        #            local sidebar = require('avante').get()

        #            local open = sidebar:is_open()
        #            -- ensure avante sidebar is open
        #            if not open then
        #              require('avante.api').ask()
        #              sidebar = require('avante').get()
        #            end

        #            sidebar.file_selector:add_selected_file(relative_path)

        #            -- remove neo tree buffer
        #            if not open then
        #              sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]')
        #            end
        #          end,
        #        },
        #        window = {
        #          mappings = {
        #            ['oa'] = 'avante_add_files',
        #          },
        #        },
        #      },
        #    })

        #    xvim.keymap.set("n", "<leader>e", "<Cmd>Neotree reveal<CR>")
        #    vim.keymap.set("n", "<leader>E", "<Cmd>Neotree toggle<CR>")
        #  '';
        #}

        ## "Use your Neovim like using Cursor AI IDE! "
        ##   https://github.com/yetone/avante.nvim
        #{
        #  plugin = avante-nvim;
        #  type = "lua";
        #  config = ''
        #    require("avante").setup({
        #      provider = "openai",
        #    })
        #  '';
        #}

        # "The default colorscheme used by AstroNvim"
        #   https://github.com/AstroNvim/astrotheme/
        #astrotheme

        # "Soho vibes for Neovim" [colorscheme]
        #   https://github.com/rose-pine/neovim/
        {
          plugin = rose-pine;
          type = "viml";

          # set theme very early so other plugins can pull in the settings e.g. bufferline
          config = ''
            " set color-scheme on gnome light/dark setting
            "
            " read gnome light/dark setting
            let theme=system('dconf read /org/gnome/desktop/interface/color-scheme')

            " set vim color scheme
            if theme =~ "default"
              " light vim color
              set background=light
              lua require("astrotheme").setup({})
              colorscheme astrojupiter
              "lua require('rose-pine').setup({groups = {background = 'ffffff'}})
              "colorscheme astrolight"
              "colorscheme rose-pine-moon
            else
              " if dark color scheme
              set background=dark
              colorscheme rose-pine-moon
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

        ## "A fancy, configurable, notification manager for NeoVim"
        ##   https://github.com/rcarriga/nvim-notify/
        #{
        #  plugin = nvim-notify;
        #  type = "lua";
        #  config = ''
        #    require("notify").setup({
        #      render = 'wrapped-compact',
        #      stages = "fade_in_slide_out",
        #      timeout = 3000,
        #    })
        #  '';
        #}

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

        ## "A git blame plugin for Neovim written in Lua"
        ##   https://github.com/f-person/git-blame.nvim
        #{
        #  plugin = git-blame-nvim;
        #  type = "lua";
        #  config = ''
        #    require('gitblame').setup {
        #      enabled = false,
        #      virtual_text_column = 60,
        #      date_format = "%r",
        #    }

        #    vim.api.nvim_set_keymap('n', ',bm', ':GitBlameToggle<CR>',{noremap = true})
        #    vim.api.nvim_set_keymap('n', ',bo', ':GitBlameOpenCommitURL<CR>',{noremap = true})
        #  '';
        #}

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

        ## "displays a popup with possible keybindings of the command you started typing"
        ##   https://github.com/folke/which-key.nvim
        {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
            local whichkey = require("which-key")

            whichkey.add({
            })
          '';
        }
        #    local M = {}
        #    M.config = function()
        #      lvim.builtin.which_key = {
        #        ---@usage disable which-key completely [not recommended]
        #        active = true,
        #        on_config_done = nil,
        #        setup = {
        #          plugins = {
        #            marks = false, -- shows a list of your marks on ' and `
        #            registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        #            spelling = {
        #              enabled = true,
        #              suggestions = 20,
        #            }, -- use which-key for spelling hints
        #            -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        #            -- No actual key bindings are created
        #            presets = {
        #              operators = false, -- adds help for operators like d, y, ...
        #              motions = false, -- adds help for motions
        #              text_objects = false, -- help for text objects triggered after entering an operator
        #              windows = false, -- default bindings on <c-w>
        #              nav = false, -- misc bindings to work with windows
        #              z = false, -- bindings for folds, spelling and others prefixed with z
        #              g = false, -- bindings for prefixed with g
        #            },
        #          },
        #          -- add operators that will trigger motion and text object completion
        #          -- to enable all native operators, set the preset / operators plugin above
        #          operators = { gc = "Comments" },
        #          key_labels = {
        #            -- override the label used to display some keys. It doesn't effect WK in any other way.
        #            -- For example:
        #            -- ["<space>"] = "SPC",
        #            -- ["<cr>"] = "RET",
        #            -- ["<tab>"] = "TAB",
        #          },
        #          icons = {
        #            breadcrumb = lvim.icons.ui.DoubleChevronRight, -- symbol used in the command line area that shows your active key combo
        #            separator = lvim.icons.ui.BoldArrowRight, -- symbol used between a key and it's label
        #            group = lvim.icons.ui.Plus, -- symbol prepended to a group
        #          },
        #          popup_mappings = {
        #            scroll_down = "<c-d>", -- binding to scroll down inside the popup
        #            scroll_up = "<c-u>", -- binding to scroll up inside the popup
        #          },
        #          window = {
        #            border = "single", -- none, single, double, shadow
        #            position = "bottom", -- bottom, top
        #            margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
        #            padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
        #            winblend = 0,
        #          },
        #          layout = {
        #            height = { min = 4, max = 25 }, -- min and max height of the columns
        #            width = { min = 20, max = 50 }, -- min and max width of the columns
        #            spacing = 3, -- spacing between columns
        #            align = "left", -- align columns left, center or right
        #          },
        #          ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
        #          hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
        #          show_help = true, -- show help message on the command line when the popup is visible
        #          show_keys = true, -- show the currently pressed key and its label as a message in the command line
        #          triggers = "auto", -- automatically setup triggers
        #          -- triggers = {"<leader>"} -- or specify a list manually
        #          triggers_blacklist = {
        #            -- list of mode / prefixes that should never be hooked by WhichKey
        #            -- this is mostly relevant for key maps that start with a native binding
        #            -- most people should not need to change this
        #            i = { "j", "k" },
        #            v = { "j", "k" },
        #          },
        #          -- disable the WhichKey popup for certain buf types and file types.
        #          -- Disabled by default for Telescope
        #          disable = {
        #            buftypes = {},
        #            filetypes = { "TelescopePrompt" },
        #     :     },
        #        },

        #        opts = {
        #          mode = "n", -- NORMAL mode
        #          prefix = "<leader>",
        #          buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
        #          silent = true, -- use `silent` when creating keymaps
        #          noremap = true, -- use `noremap` when creating keymaps
        #          nowait = true, -- use `nowait` when creating keymaps
        #        },
        #        vopts = {
        #          mode = "v", -- VISUAL mode
        #          prefix = "<leader>",
        #          buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
        #          silent = true, -- use `silent` when creating keymaps
        #          noremap = true, -- use `noremap` when creating keymaps
        #          nowait = true, -- use `nowait` when creating keymaps
        #        },
        #        -- NOTE: Prefer using : over <cmd> as the latter avoids going back in normal-mode.
        #        -- see https://neovim.io/doc/user/map.html#:map-cmd
        #        vmappings = {
        #          ["/"] = { "<Plug>(comment_toggle_linewise_visual)", "Comment toggle linewise (visual)" },
        #          l = {
        #            name = "LSP",
        #            a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
        #          },
        #          g = {
        #            name = "Git",
        #            r = { "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk" },
        #            s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk" },
        #          },
        #        },
        #        mappings = {
        #          [";"] = { "<cmd>Alpha<CR>", "Dashboard" },
        #          ["w"] = { "<cmd>w!<CR>", "Save" },
        #          ["q"] = { "<cmd>confirm q<CR>", "Quit" },
        #          ["/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment toggle current line" },
        #          ["c"] = { "<cmd>BufferKill<CR>", "Close Buffer" },
        #          ["f"] = {
        #            function()
        #              require("lvim.core.telescope.custom-finders").find_project_files { previewer = false }
        #            end,
        #            "Find File",
        #          },
        #          ["h"] = { "<cmd>nohlsearch<CR>", "No Highlight" },
        #          ["e"] = { "<cmd>NvimTreeToggle<CR>", "Explorer" },
        #          b = {
        #            name = "Buffers",
        #            j = { "<cmd>BufferLinePick<cr>", "Jump" },
        #            f = { "<cmd>Telescope buffers previewer=false<cr>", "Find" },
        #            b = { "<cmd>BufferLineCyclePrev<cr>", "Previous" },
        #            n = { "<cmd>BufferLineCycleNext<cr>", "Next" },
        #            W = { "<cmd>noautocmd w<cr>", "Save without formatting (noautocmd)" },
        #            -- w = { "<cmd>BufferWipeout<cr>", "Wipeout" }, -- TODO: implement this for bufferline
        #            e = {
        #              "<cmd>BufferLinePickClose<cr>",
        #              "Pick which buffer to close",
        #            },
        #            h = { "<cmd>BufferLineCloseLeft<cr>", "Close all to the left" },
        #            l = {
        #              "<cmd>BufferLineCloseRight<cr>",
        #              "Close all to the right",
        #            },
        #            D = {
        #              "<cmd>BufferLineSortByDirectory<cr>",
        #              "Sort by directory",
        #            },
        #            L = {
        #              "<cmd>BufferLineSortByExtension<cr>",
        #              "Sort by language",
        #            },
        #          },
        #          d = {
        #            name = "Debug",
        #            t = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
        #            b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
        #            c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
        #            C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
        #            d = { "<cmd>lua require'dap'.disconnect()<cr>", "Disconnect" },
        #            g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
        #            i = { "<cmd>lua require'dap'.step_into()<cr>", "Step Into" },
        #            o = { "<cmd>lua require'dap'.step_over()<cr>", "Step Over" },
        #            u = { "<cmd>lua require'dap'.step_out()<cr>", "Step Out" },
        #            p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
        #            r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Toggle Repl" },
        #            s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
        #            q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
        #            U = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
        #          },
        #          p = {
        #            name = "Plugins",
        #            i = { "<cmd>Lazy install<cr>", "Install" },
        #            s = { "<cmd>Lazy sync<cr>", "Sync" },
        #            S = { "<cmd>Lazy clear<cr>", "Status" },
        #            c = { "<cmd>Lazy clean<cr>", "Clean" },
        #            u = { "<cmd>Lazy update<cr>", "Update" },
        #            p = { "<cmd>Lazy profile<cr>", "Profile" },
        #            l = { "<cmd>Lazy log<cr>", "Log" },
        #            d = { "<cmd>Lazy debug<cr>", "Debug" },
        #          },

        #          -- " Available Debug Adapters:
        #          -- "   https://microsoft.github.io/debug-adapter-protocol/implementors/adapters/
        #          -- " Adapter configuration and installation instructions:
        #          -- "   https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
        #          -- " Debug Adapter protocol:
        #          -- "   https://microsoft.github.io/debug-adapter-protocol/
        #          -- " Debugging
        #          g = {
        #            name = "Git",
        #            g = { "<cmd>lua require 'lvim.core.terminal'.lazygit_toggle()<cr>", "Lazygit" },
        #            j = { "<cmd>lua require 'gitsigns'.nav_hunk('next', {navigation_message = false})<cr>", "Next Hunk" },
        #            k = { "<cmd>lua require 'gitsigns'.nav_hunk('prev', {navigation_message = false})<cr>", "Prev Hunk" },
        #            l = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
        #            L = { "<cmd>lua require 'gitsigns'.blame_line({full=true})<cr>", "Blame Line (full)" },
        #            p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
        #            r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
        #            R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
        #            s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
        #            u = {
        #              "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
        #              "Undo Stage Hunk",
        #            },
        #            o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
        #            b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        #            c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
        #            C = {
        #              "<cmd>Telescope git_bcommits<cr>",
        #              "Checkout commit(for current file)",
        #            },
        #            d = {
        #              "<cmd>Gitsigns diffthis HEAD<cr>",
        #              "Git Diff",
        #            },
        #          },
        #          l = {
        #            name = "LSP",
        #            a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
        #            d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
        #            w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
        #            f = { "<cmd>lua require('lvim.lsp.utils').format()<cr>", "Format" },
        #            i = { "<cmd>LspInfo<cr>", "Info" },
        #            I = { "<cmd>Mason<cr>", "Mason Info" },
        #            j = {
        #              "<cmd>lua vim.diagnostic.goto_next()<cr>",
        #              "Next Diagnostic",
        #            },
        #            k = {
        #              "<cmd>lua vim.diagnostic.goto_prev()<cr>",
        #              "Prev Diagnostic",
        #            },
        #            l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
        #            q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
        #            r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
        #            s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
        #            S = {
        #              "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        #              "Workspace Symbols",
        #            },
        #            e = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
        #          },
        #          L = {
        #            name = "+LunarVim",
        #            c = {
        #              "<cmd>edit " .. get_config_dir() .. "/config.lua<cr>",
        #              "Edit config.lua",
        #            },
        #            d = { "<cmd>LvimDocs<cr>", "View LunarVim's docs" },
        #            f = {
        #              "<cmd>lua require('lvim.core.telescope.custom-finders').find_lunarvim_files()<cr>",
        #              "Find LunarVim files",
        #            },
        #            g = {
        #              "<cmd>lua require('lvim.core.telescope.custom-finders').grep_lunarvim_files()<cr>",
        #              "Grep LunarVim files",
        #            },
        #            k = { "<cmd>Telescope keymaps<cr>", "View LunarVim's keymappings" },
        #            i = {
        #              "<cmd>lua require('lvim.core.info').toggle_popup(vim.bo.filetype)<cr>",
        #              "Toggle LunarVim Info",
        #            },
        #            I = {
        #              "<cmd>lua require('lvim.core.telescope.custom-finders').view_lunarvim_changelog()<cr>",
        #              "View LunarVim's changelog",
        #            },
        #            l = {
        #              name = "+logs",
        #              d = {
        #                "<cmd>lua require('lvim.core.terminal').toggle_log_view(require('lvim.core.log').get_path())<cr>",
        #                "view default log",
        #              },
        #              D = {
        #                "<cmd>lua vim.fn.execute('edit ' .. require('lvim.core.log').get_path())<cr>",
        #                "Open the default logfile",
        #              },
        #              l = {
        #                "<cmd>lua require('lvim.core.terminal').toggle_log_view(vim.lsp.get_log_path())<cr>",
        #                "view lsp log",
        #              },
        #              L = { "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<cr>", "Open the LSP logfile" },
        #              n = {
        #                "<cmd>lua require('lvim.core.terminal').toggle_log_view(os.getenv('NVIM_LOG_FILE'))<cr>",
        #                "view neovim log",
        #              },
        #              N = { "<cmd>edit $NVIM_LOG_FILE<cr>", "Open the Neovim logfile" },
        #            },
        #            r = { "<cmd>LvimReload<cr>", "Reload LunarVim's configuration" },
        #            u = { "<cmd>LvimUpdate<cr>", "Update LunarVim" },
        #          },
        #          s = {
        #            name = "Search",
        #            b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        #            c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
        #            f = { "<cmd>Telescope find_files<cr>", "Find File" },
        #            h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
        #            H = { "<cmd>Telescope highlights<cr>", "Find highlight groups" },
        #            M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
        #            r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
        #            R = { "<cmd>Telescope registers<cr>", "Registers" },
        #            t = { "<cmd>Telescope live_grep<cr>", "Text" },
        #            k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
        #            C = { "<cmd>Telescope commands<cr>", "Commands" },
        #            l = { "<cmd>Telescope resume<cr>", "Resume last search" },
        #            p = {
        #              "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
        #              "Colorscheme with Preview",
        #            },
        #          },
        #          T = {
        #            name = "Treesitter",
        #            i = { ":TSConfigInfo<cr>", "Info" },
        #          },
        #        },
        #      }
        #    end

        #    M.setup = function()
        #      local which_key = require "which-key"

        #      which_key.setup(lvim.builtin.which_key.setup)

        #      local opts = lvim.builtin.which_key.opts
        #      local vopts = lvim.builtin.which_key.vopts

        #      local mappings = lvim.builtin.which_key.mappings
        #      local vmappings = lvim.builtin.which_key.vmappings

        #      which_key.register(mappings, opts)
        #      which_key.register(vmappings, vopts)

        #      if lvim.builtin.which_key.on_config_done then
        #        lvim.builtin.which_key.on_config_done(which_key)
        #      end
        #    end

        #    return M
        #  '';
        #}

        # "Peek lines just when you intend"
        #   https://github.com/nacro90/numb.nvim/
        {
          plugin = numb-nvim;
          type = "lua";
          config = "require('numb').setup()";
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

      extraLuaConfig = ''
        -- map leader to <Space>
        vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
        vim.g.mapleader = " "

        -- unmap esc to retrain myself on jj
        vim.keymap.set("i", "<Esc>", "<Nop>", { noremap = true, silent = true })
      '';
    };
  };
}
