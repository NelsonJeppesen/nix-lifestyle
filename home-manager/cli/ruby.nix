# Provide Ruby and RSpec together so the interpreter can find the test gems.
{ pkgs, ... }:
{
  home.packages = [
    (pkgs.ruby.withPackages (rubyPackages: [
      rubyPackages.rspec # Ruby behavior-driven test runner
    ]))
  ];
}
