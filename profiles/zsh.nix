{ config, pkgs, stdenv, lib, ... }:

{
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;

  programs.starship = {
    enable = lib.mkDefault true;
    settings = {
      # Disabled
      aws.disabled = true;
      helm.disabled = true;
      terraform.disabled = true;

      # Enabled
      kubernetes.disabled = false;
    };
  };
}
