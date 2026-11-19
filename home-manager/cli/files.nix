# Map static CLI configuration and launchers into the user home.
{ config, ... }: {
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
  home.file.".config/curlrc".source = ./dotfiles/curlrc; # curl defaults (--no-progress-meter)
  home.file.".terraform-version".source = ./dotfiles/terraform-version; # default to latest
  home.file.".config/fend/config.toml".source = ./dotfiles/fend.toml; # fend calculator config
  home.file.".config/zsh/named-dirs.zsh".source = ./dotfiles/zsh-named-dirs.zsh; # Project ~name aliases
  home.file.".digrc".source = ./dotfiles/digrc; # dig defaults (+noall +answer)
  home.file.".local/bin/update" = {
    source = ./dotfiles/update;
    executable = true;
  };
  home.file.".local/bin/firmware-update" = {
    source = ./dotfiles/firmware-update;
    executable = true;
  };
  home.file.".local/bin/n" = {
    source = ./dotfiles/n;
    executable = true;
  };
  home.file.".terraform.d/plugin-cache/.empty".source = ./dotfiles/empty; # Ensure terraform plugin cache dir exists
}
