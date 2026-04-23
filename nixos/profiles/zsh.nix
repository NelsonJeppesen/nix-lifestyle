# zsh.nix - Note: this profile is functionally redundant with shared.nix,
# which already enables zsh and sets it as the default shell. Kept for
# machines that import only this and not shared.nix (currently none).
{ config, pkgs, stdenv, lib, ... }:

{
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
