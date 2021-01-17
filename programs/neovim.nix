{ config, pkgs, ... }:
{
  programs = {

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      #defaultEditor = true;

      configure = {

        customRC = ''
          " enable true color
          set termguicolors
          colorscheme gruvbox

          " autocompletion (deoplete)
          inoremap <silent><expr> <Tab>  pumvisible() ? "<C-n>" : "<Tab>"
          let g:deoplete#enable_at_startup = 1

          " copy everything to the clipboard
          command! CopyToClipboard :%y+
          set clipboard=unnamedplus

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

        packages.myVimPackage = {
          start = with pkgs.vimPlugins; [
            ale
            deoplete-nvim
            gruvbox-community
            neovim-sensible
            #nvim-lspconfig
            vim-airline
            vim-airline-themes
            vim-gitgutter
            vim-nix
            vim-better-whitespace
          ] ;
        };
      };
    };
  };
}
