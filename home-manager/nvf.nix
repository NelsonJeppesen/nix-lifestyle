# nvf.nix - second Neovim, configured entirely through Nix options
#
# neovim.nix ships LazyVim: a Lua distribution that Nix only packages. This
# ships nvf (NotAShelf/nvf), where every plugin, mapping and LSP is a Nix
# option and the Lua is generated. Both are installed at once on purpose, to
# compare the two approaches on the same machine:
#
#   nvim / vim  -> LazyVim  (neovim.nix)
#   nvf         -> nvf      (this file)
#
# Two implementation notes:
# - nvf is built with `neovimConfiguration` rather than through its
#   home-manager module. That module puts a package providing `bin/nvim` into
#   home.packages, which collides with the one LazyVim's module puts there.
#   The wrapper below publishes `nvf` and the config-printing helpers only.
# - nvf's wrapper sets NVIM_APPNAME=nvf, so shada, undo history and sessions
#   live under ~/.local/{share,state}/nvf and never mix with LazyVim's.
{ pkgs, nvf, ... }:
let
  arrowKeys = [
    "<Up>"
    "<Down>"
    "<Left>"
    "<Right>"
  ];

  editor = nvf.lib.neovimConfiguration {
    inherit pkgs;
    modules = [
      {
        vim = {
          # `vi` and `vim` stay pointed at LazyVim (see neovim.nix).
          viAlias = false;
          vimAlias = false;

          lineNumberMode = "relNumber";
          preventJunkFiles = true; # no swap or backup files
          searchCase = "smart";
          undoFile.enable = true;
          spellcheck.enable = false; # typos-lsp covers prose in code instead

          clipboard = {
            enable = true;
            registers = "unnamedplus";
            providers.wl-copy.enable = true; # GNOME Wayland
          };

          options = {
            expandtab = true;
            shiftwidth = 2;
            softtabstop = 2;
            foldenable = false; # folding off, as in the LazyVim config
          };

          # ── Languages ────────────────────────────────────────────
          # Per-language treesitter, formatting and linting default to these,
          # so each entry below only names what differs from nvf's defaults.
          languages = {
            enableTreesitter = true;
            enableFormat = true;
            enableExtraDiagnostics = true; # statix, shellcheck, hadolint, ...

            bash.enable = true;
            docker.enable = true;
            jinja.enable = true; # Ansible templates
            json.enable = true;
            lua.enable = true;
            markdown = {
              enable = true;
              format.type = [ "prettier" ]; # nvf defaults to deno
            };
            nix = {
              enable = true;
              lsp.servers = [ "nixd" ]; # nvf defaults to nil
              format.type = [ "nixfmt" ]; # repo convention, not alejandra
            };
            ruby = {
              enable = true;
              lsp.servers = [ "ruby-lsp" ]; # nvf defaults to solargraph
            };
            yaml.enable = true;

            # terraform-ls over tofu-ls for both, and no formatter: `terraform
            # fmt` would pull the (unfree) terraform binary into the closure,
            # while projects here get theirs from mise.
            hcl = {
              enable = true;
              lsp.servers = [ "terraform-ls" ];
              format.enable = false;
            };
            terraform = {
              enable = true;
              lsp.servers = [ "terraform-ls" ];
              format.enable = false;
            };
          };

          treesitter = {
            enable = true;
            fold = false;
            indent.enable = true;
            textobjects.enable = true;
            # Same grammar set as neovim.nix, so highlighting does not stop at
            # the languages enabled above.
            grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;
          };

          # ── LSP and diagnostics ──────────────────────────────────
          lsp = {
            enable = true;
            formatOnSave = true;
            lspkind.enable = true;
            lspSignature.enable = true;
            trouble.enable = true;

            # typos-lsp has no nvf module; lspconfig.sources takes raw Lua
            # that runs after nvim-lspconfig has been set up.
            lspconfig.sources.typos-lsp = ''
              vim.lsp.config("typos_lsp", { cmd = { "${pkgs.typos-lsp}/bin/typos-lsp" } })
              vim.lsp.enable("typos_lsp")
            '';
          };

          diagnostics = {
            enable = true;
            nvim-lint.enable = true;
          };

          # ── Completion and AI ────────────────────────────────────
          autocomplete.blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
          };

          # nvf wires Copilot into nvim-cmp only, so alongside blink.cmp the
          # suggestions stay inline (ghost text) rather than joining the
          # completion menu.
          assistant.copilot.enable = true;

          # ── Editing ──────────────────────────────────────────────
          comments.comment-nvim.enable = true;
          notes.todo-comments.enable = true;
          mini = {
            ai.enable = true;
            pairs.enable = true;
            surround.enable = true;
          };
          utility = {
            motion.flash-nvim.enable = true;
            oil-nvim = {
              enable = true;
              gitStatus.enable = true;
            };
          };

          # ── Git ──────────────────────────────────────────────────
          git = {
            enable = true;
            gitsigns.enable = true;
            git-conflict.enable = true; # [x / ]x between conflicts
          };

          # ── UI ───────────────────────────────────────────────────
          # nvf has no system light/dark listener, so unlike LazyVim this one
          # stays on the dark variant.
          theme = {
            enable = true;
            name = "tokyonight";
            style = "night";
          };
          statusline.lualine.enable = true;
          tabline.nvimBufferline.enable = true;
          telescope.enable = true;
          terminal.toggleterm.enable = true; # <c-t>
          binds.whichKey.enable = true;
          ui = {
            borders.enable = true;
            breadcrumbs.enable = true; # navic in the winbar
            illuminate.enable = true;
            noice.enable = true;
          };
          visuals = {
            indent-blankline.enable = true;
            nvim-web-devicons.enable = true;
          };

          # ── Keymaps ──────────────────────────────────────────────
          keymaps =
            map (key: {
              inherit key;
              mode = [
                "i"
                "v"
              ];
              action = "<Nop>";
              desc = "Arrow keys are disabled";
            }) arrowKeys
            ++ map (key: {
              inherit key;
              mode = "n";
              action = "<cmd>echo 'Arrow keys are disabled'<cr>";
              desc = "Arrow keys are disabled";
            }) arrowKeys
            ++ [
              {
                key = "<leader>e";
                mode = "n";
                action = "<cmd>Oil<cr>";
                desc = "Oil (parent dir)";
              }
              {
                key = "<leader>by";
                mode = "n";
                action = "<cmd>%y+<cr>";
                desc = "Yank buffer to clipboard";
              }
              {
                key = "<leader>bq";
                mode = "n";
                action = "<cmd>%!jq .<cr>";
                desc = "Format buffer as JSON (jq)";
              }
            ];
        };
      }
    ];
  };

  # neovimConfiguration always names the binary `nvim`. Republish it as `nvf`
  # so it can sit next to LazyVim's `nvim` in home.packages, keeping nvf's
  # own config-printing helpers.
  nvfCommand = pkgs.runCommand "nvf-command" { meta.mainProgram = "nvf"; } ''
    mkdir -p "$out/bin"
    ln -s ${editor.neovim}/bin/nvim "$out/bin/nvf"
    for helper in ${editor.neovim}/bin/nvf-*; do
      ln -s "$helper" "$out/bin/$(basename "$helper")"
    done
  '';
in
{
  home.packages = [ nvfCommand ];
}
