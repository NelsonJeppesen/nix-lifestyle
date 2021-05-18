{ config, pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins =
        with pkgs.vimPlugins; [
         #neovim-sensible
         #nvim-lspconfig
         #vim-grammarous
         ale
         deoplete-nvim
         gruvbox-community
         vim-airline
         vim-airline-themes
         vim-better-whitespace
         vim-gitgutter
         vim-nix
         vim-table-mode
        ];

      extraConfig = ''
        " set title in Kitty term tab to just the filename
        set titlestring=%t
        set title

        " github markdown compat table mode
        let g:table_mode_corner='|'

        " enable true color
        set termguicolors
        colorscheme gruvbox
        set number

        " autocompletion (deoplete)
        inoremap <silent><expr> <Tab>  pumvisible() ? "<C-n>" : "<Tab>"
        let g:deoplete#enable_at_startup = 1

        " copy everything to the clipboard
        command! CopyToClipboard :%y+
        set clipboard=unnamedplus

        " enable mouse
        set mouse=a

        " Set leader:
        map , <Leader>
        set updatetime=70
        let g:ale_sign_column_always = 1

        " Indentation settings for using 2 spaces instead of tabs.
        set shiftwidth=2
        set softtabstop=2
        set expandtab

        " Use case-insensitive search
        set ignorecase

        " cant spell
        set spelllang=en
        nnoremap <silent> <Leader>s :call ToggleSpellCheck()<CR>

        '';
    };
  };
}
