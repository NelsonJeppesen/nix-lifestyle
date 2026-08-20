# ruby.nix - Ruby runtime and testing tools
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.ruby.withPackages (rubyPackages: [
      rubyPackages.rspec # Ruby behavior-driven test runner
    ]))
  ];
}
