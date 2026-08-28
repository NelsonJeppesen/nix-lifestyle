{ pkgs, ... }:
{
  home.packages = [ pkgs.mise ];

  programs.zsh.initContent = ''
    eval "$(${pkgs.mise}/bin/mise activate zsh)"
  '';
}
