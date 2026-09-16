{ ... }: {
  programs.nvf = {
    enable = true;
    defaultEditor = true; # $EDITOR

    settings = {
      mnw.appName = null;

      vim = {
        viAlias = true;
        vimAlias = true;
        opts.expandtab = true;

        spellcheck = {
          enable = true;
          programmingWordlist.enable = true; # camelCase-aware word list
        };

        #  LSP
        lsp = {
          enable = true; # language modules hook into this
          formatOnSave = true;
          lightbulb.enable = true; # code action indicator in the gutter
          trouble.enable = true; # diagnostics list
          otter-nvim.enable = true; # LSP inside embedded code blocks
          nvim-docs-view.enable = true; # docs side panel
          presets.harper.enable = true; # prose checker
          # lspsaga and lspkind are disabled.
        };

        debugger.nvim-dap = {
          enable = true;
          ui.enable = true;
        };

        #  Languages  Treesitter, formatting and extra linting are on for every language enabled below.
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          bash.enable = true;
          docker.enable = true;
          env.enable = true;
          json.enable = true;
          lua.enable = true;
          nix.enable = true;
          python.enable = true;
          sql.enable = true;
          toml.enable = true;
        };

        #  Visuals
        visuals = {
          # blink-indent.enable = true; # indent guides
          cinnamon-nvim.enable = true; # smooth scrolling
          fidget-nvim.enable = true; # LSP progress
          highlight-undo.enable = true; # flash undone text
          indent-blankline.enable = true; # indent guides
          nvim-cursorline.enable = true;
          nvim-scrollbar.enable = true;
          # nvim-web-devicons.enable = true;
        };

        statusline.lualine = {
          enable = true;
          integrations.breadcrumbs = {
            nvim-navic.enable = true; # winbar breadcrumbs
            navbuddy.enable = true; # symbol tree navigator
          };
        };

        theme = {
          enable = true;
          name = "tokyonight";
          style = "night";
        };

        #  Editing
        autopairs.nvim-autopairs.enable = true;
        autocomplete.blink-cmp.enable = true; # nvim-cmp stays off
        snippets.luasnip.enable = true;
        comments.comment-nvim.enable = true;
        treesitter.context.enable = true; # sticky scope header

        #  Navigation and UI
        filetree.neo-tree.enable = true;
        tabline.nvimBufferline.enable = true;
        telescope.enable = true;
        projects.project-nvim.enable = true;
        minimap.minimap-vim.enable = true;
        dashboard.alpha.enable = true;
        notify.nvim-notify.enable = true;
        notes.todo-comments.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        terminal.toggleterm = {
          enable = true;
          lazygit.enable = true;
        };

        ui = {
          borders.enable = true;
          colorizer.enable = true; # renders colour codes
          fastaction.enable = true; # quick code action picker
          illuminate.enable = true; # highlight other uses of the word
          noice.enable = true; # command line and message UI
          smartcolumn = {
            enable = true;
            setupOpts.custom_colorcolumn = {
              nix = "110";
              ruby = "120";
              java = "130";
              go = [
                "90"
                "130"
              ];
            };
          };
        };

        #  Git
        git = {
          enable = true;
          gitsigns.enable = true;
          # gitsigns.codeActions stays off: it emits a debug message on every attach.
          neogit.enable = true;
        };

        #  Utilities
        utility = {
          diffview-nvim.enable = true;
          grug-far-nvim.enable = true; # project-wide search and replace
          icon-picker.enable = true;
          leetcode-nvim.enable = true;
          multicursors.enable = true;
          nvim-biscuits.enable = true; # context on closing brackets
          smart-splits.enable = true; # window and pane movement
          surround.enable = true;
          undotree.enable = true;
          images.img-clip.enable = true; # paste images from the clipboard
          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = true; # shows available motions
          };
        };

        assistant = {
          avante-nvim.enable = true;
          # Copilot itself is off; this only takes effect once it is enabled.
          copilot.cmp.enable = true;
        };

        # Mini modules
        mini = {
          # Sensible option defaults and the `\` prefix for toggling options.
          basics.enable = true;
          # Richer `a`/`i` text objects: arguments, brackets, quotes, tags.
          ai.enable = true;
        };
      };
    };
  };

  # nvf's module sets only EDITOR.
  home.sessionVariables.VISUAL = "nvim";
}
