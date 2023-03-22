{ config, pkgs, stdenv, lib, ... }:

{
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
