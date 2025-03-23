# neovim: my cozy home for code and configuration
{ config, pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      vimAlias = true;
      withNodeJs = true;

      extraLuaPackages =
        luaPkgs: with luaPkgs; [
          middleclass # used by windows-nvim
        ];

      # Install Vim Plugins, keep configuration local to install block if possible
      plugins = with pkgs.vimPlugins; [

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

        # "The default colorscheme used by AstroNvim"
        #   https://github.com/AstroNvim/astrotheme/
        astrotheme

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

        # "Neovim plugin for splitting/joining blocks of code "
        #   https://github.com/Wansmer/treesj/
        {
          plugin = treesj;
          type = "lua";
          config = "require('treesj').setup()";
        }

        # "Show code context" (tree-sitter)
        #   https://github.com/nvim-treesitter/nvim-treesitter-context/
        {
          plugin = nvim-treesitter-context;
          type = "lua";
          config = ''
            require'treesitter-context'.setup{
              enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
              max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
              min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
              line_numbers = true,
              multiline_threshold = 30, -- Maximum number of lines to show for a single context
              trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
              mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
              -- Separator between context and content. Should be a single character string, like '-'.
              -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
              separator = nil,
              zindex = 20, -- The Z-index of the context window
              on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
            }

            vim.keymap.set("n", "[c", function()
              require("treesitter-context").go_to_context(vim.v.count1)
            end, { silent = true })
          '';
        }
        {
          plugin = nvim-surround;
          type = "lua";
          config = ''require("nvim-surround").setup({})'';
        }

        {
          plugin = mini-nvim;
          type = "lua";
          config = ''
            require('mini.basics').setup({ options = { extra_ui = true }})
            require('mini.trailspace').setup()
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

        # https://github.com/iamcco/markdown-preview.nvim/
        #   "markdown preview plugin for (neo)vim"
        markdown-preview-nvim

        # "Configurable tools for working with Markdown in Neovim. "
        #   https://github.com/tadmccorkle/markdown.nvim/
        {
          plugin = markdown-nvim;
          type = "lua";
          config = ''require("markdown").setup({})'';
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
            nnoremap <silent> <C-left>  :BufferLineCyclePrev<CR>
            nnoremap <silent> <C-right> :BufferLineCycleNext<CR>
            nnoremap <silent> <C-up>    <C-w>w
            nnoremap <silent> <C-down>  <C-w>w
          '';
        }

        # SQLite LuaJIT binding with a very simple api.
        #   https://github.com/kkharji/sqlite.lua/
        # used by: nvim-neoclip
        #{
        #  plugin = sqlite-lua;
        #  config = "let g:sqlite_clib_path = '${pkgs.sqlite.out}/lib/libsqlite3.so'";
        #}

        ## Clipboard manager neovim plugin with telescope integration
        ##   https://github.com/AckslD/nvim-neoclip.lua
        #{
        #  plugin = nvim-neoclip-lua;
        #  type = "lua";
        #  config = ''
        #    require('neoclip').setup({
        #      continuous_sync = true,
        #      enable_persistent_history = true,
        #      history = 9999,
        #    })
        #  '';
        #}

        # "A fancy, configurable, notification manager for NeoVim"
        #   https://github.com/rcarriga/nvim-notify/
        {
          plugin = nvim-notify;
          type = "lua";
          config = ''
            require("notify").setup({
              render = 'wrapped-compact',
              stages = "fade_in_slide_out",
              timeout = 3000,
            })
          '';
        }

        # "💥 Highly experimental plugin that completely replaces the UI for
        # messages, cmdline and the popupmenu"
        #   https://github.com/folke/noice.nvim/
        {
          plugin = noice-nvim;
          type = "lua";
          config = ''
            require('noice').setup({
              })
            vim.keymap.set("n", "<leader>nl", ":Noice last<cr>")
            vim.keymap.set("n", "<leader>nh", ":Noice history<cr>")
            vim.keymap.set("n", "<leader>nc", ":Noice dismiss<cr>")
            vim.keymap.set("n", "<leader>ne", ":Noice errors<cr>")
            vim.keymap.set("n", "<leader>nt", ":Noice telescope<cr>")
          '';
        }

        # "Highlight changed text after Undo / Redo operations"
        #   https://github.com/tzachar/highlight-undo.nvim/
        #{
        #  plugin = highlight-undo-nvim;
        #  type = "lua";
        #  config = ''require('highlight-undo').setup({duration = 2000})'';
        #}

        # "A telescope extension to view and search your undo tree 🌴"
        #   https://github.com/debugloop/telescope-undo.nvim/
        telescope-undo-nvim

        #   https://github.com/nvim-telescope/telescope.nvim
        #   "highly extendable fuzzy finder over lists"
        {
          plugin = telescope-nvim;
          type = "viml";
          config = ''
            nnoremap  ,,/  <cmd>Telescope current_buffer_fuzzy_find<cr>
            nnoremap  ,,b  <cmd>Telescope buffers<cr>
            nnoremap  ,,c  <cmd>Telescope command_history<cr>
            nnoremap  ,,f  <cmd>Telescope find_files<cr>
            "nnoremap  ,,p  <cmd>Telescope neoclip<cr>
            nnoremap  ,,u  <cmd>Telescope undo<cr>

            nnoremap  ,,g  :execute 'Telescope git_files cwd=' . expand('%:p:h')<cr>
            nnoremap  ,,h  <cmd>lua require('telescope.builtin').oldfiles()<cr>
            nnoremap  ,,o  <cmd>lua require('telescope.builtin').file_browser()<cr>
            nnoremap  ,,r  <cmd>lua require('telescope.builtin').registers()<cr>


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

              -- require('telescope').load_extension('neoclip')
              require('telescope').load_extension('undo')
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
            nnoremap <silent> <c-\>     <cmd>execute 'ToggleTerm direction=float      dir=' . expand('%:p:h')<CR>
            nnoremap <silent> <S-c-\>   <cmd>execute 'ToggleTerm direction=horizontal dir=' . expand('%:p:h')<CR>
            inoremap <silent> <c-\>     <esc><cmd>execute 'ToggleTerm dir=' . expand('%:p:h')<CR>
            tnoremap <silent> <c-\>     <esc><cmd>ToggleTerm<CR>
            tnoremap <silent> <S-c-\>   <esc><cmd>ToggleTerm<CR>
          '';
        }

        {
          plugin = formatter-nvim;
          type = "lua";
          config = ''
            local util = require "formatter.util"
            require("formatter").setup {
              logging = true,
              log_level = vim.log.levels.WARN,
              filetype = {
                ["terraform-vars"]  = { require("formatter.filetypes.terraform").terraformfmt},
                nix                 = { require("formatter.filetypes.nix").nixfmt},
                python              = { require("formatter.filetypes.python").black},
                ruby                = { require("formatter.filetypes.ruby").rubocop},
                sh                  = { require("formatter.filetypes.sh").shfmt},
                terraform           = { require("formatter.filetypes.terraform").terraformfmt},
                yaml                = { require("formatter.filetypes.yaml").yamlfmt},

                hcl = {
                  function()
                    return {
                      exe = "packer",
                      args = {
                          "fmt",
                          "-",
                      },
                      stdin = true,
                    }
                  end
                },
                javascript = {
                  function()
                    return {
                      exe = "biome",
                      args = {
                          "format",
                          "--indent-style=space",
                          "--stdin-file-path",
                          util.escape_path(util.get_current_buffer_file_path()),
                      },
                      stdin = true,
                    }
                  end
                },
                json      = {
                  function()
                    return {
                      exe = "biome",
                      args = {
                          "format",
                          "--indent-style=space",
                          "--stdin-file-path",
                          util.escape_path(util.get_current_buffer_file_path()),
                      },
                      stdin = true,
                    }
                  end
                },
              }
            }
            vim.api.nvim_set_keymap('n', ',a', ':Format<CR>',{noremap = true})
          '';
        }

        # "A git blame plugin for Neovim written in Lua"
        #   https://github.com/f-person/git-blame.nvim
        {
          plugin = git-blame-nvim;
          type = "lua";
          config = ''
            require('gitblame').setup {
              enabled = false,
              virtual_text_column = 60,
              date_format = "%r",
            }

            vim.api.nvim_set_keymap('n', ',bm', ':GitBlameToggle<CR>',{noremap = true})
            vim.api.nvim_set_keymap('n', ',bo', ':GitBlameOpenCommitURL<CR>',{noremap = true})
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

        # "A completion plugin for neovim coded in Lua"
        #   https://github.com/hrsh7th/nvim-cmp
        cmp-buffer
        cmp-cmdline
        cmp-nvim-lsp
        cmp-path
        cmp-treesitter
        nvim-lspconfig
        {
          plugin = nvim-cmp;
          type = "lua";
          config = ''
            local cmp = require'cmp'

            cmp.setup({
              sources = cmp.config.sources({
               {name = 'buffer'     },
               {name = 'nvim_lsp'   },
               {name = 'path'       },
               {name = 'treesitter' },
              }),

              window = {
                completion    = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
              },

              mapping = {
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ["<S-Tab>"] = cmp.mapping.select_prev_item( { behavior = cmp.SelectBehavior.Insert }),
                ["<Tab>"]   = cmp.mapping.select_next_item( { behavior = cmp.SelectBehavior.Insert }),
              },
            })

            -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline({ '/', '?' }, {
              mapping = cmp.mapping.preset.cmdline(),
              sources = {
                { name = 'buffer' }
              }
            })

            -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
            cmp.setup.cmdline(':', {
              mapping = cmp.mapping.preset.cmdline(),
              sources = cmp.config.sources({
                { name = 'path' }
              }, {
                { name = 'cmdline' }
              }),
              matching = { disallow_symbol_nonprefix_matching = false }
            })


            -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- advertise capabilities and enable plugins
            vim.lsp.set_log_level("off")
            require'lspconfig'
            require'lspconfig'.terraformls.setup{
              cmd = {'${pkgs.terraform-ls}/bin/terraform-ls', 'serve'},
              capabilities = capabilities,
            }
          '';
        }

        # "displays a popup with possible keybindings of the command you started typing"
        #   https://github.com/folke/which-key.nvim
        {
          plugin = which-key-nvim;
          type = "lua";
          config = ''
            require("which-key")
          '';
        }

        # "Peek lines just when you intend"
        #   https://github.com/nacro90/numb.nvim/
        {
          plugin = numb-nvim;
          type = "lua";
          config = "require('numb').setup()";
        }

        # ------------------------------------ Vimscript Plugins ---------------------------------------------

        # "Intelligently reopen files at your last edit position in Vim"
        #   https://github.com/farmergreg/vim-lastplace
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

        set autoread
        let mapleader=","
        nnoremap <leader>bc  :%y+<CR>
        nnoremap <leader>bb  :%!base64 -d<CR>
        nnoremap <leader>bg  :%!base64 -d\|gzip -d<CR>
        nnoremap <leader>bj  :%!jq .<CR>
        nnoremap <leader>by  :%!yq -y .<CR>

        nnoremap <leader>q :q!<CR>

        " persistent undo
        if !isdirectory($HOME."/.config/nvim/undo")
            call mkdir($HOME."/.config/nvim/undo", "", 0700)
        endif
        set undodir=~/.config/nvim/undo

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

        set list listchars=tab:→\ ,

        " disable swp
        set noswapfile

        " ALWAYS keep cursor centered
        set scrolloff=15

        set wrap
      '';

      extraLuaConfig = '''';
    };
  };
}
