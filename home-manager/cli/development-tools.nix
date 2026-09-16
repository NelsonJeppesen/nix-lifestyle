{ pkgs, ... }:
{
  home.packages = [
    pkgs.ast-grep # AST-aware structural search, linting, and rewriting
  ];
}
