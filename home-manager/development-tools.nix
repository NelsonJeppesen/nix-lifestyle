# development-tools.nix - Cross-language structural search tools
{ pkgs, ... }:
{
  home.packages = [
    pkgs.ast-grep # AST-aware structural search, linting, and rewriting
  ];
}
