# gh-dash.nix - GitHub dashboard with tuicr PR review integration
{ pkgs, tuicr, ... }:
let
  tuicrPackage = tuicr.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  programs.gh-dash = {
    enable = true;

    settings = {
      prSections = [
        {
          title = "My Pull Requests";
          filters = "is:open author:@me sort:updated-desc";
        }
        {
          title = "Review Requested";
          filters = "is:open review-requested:@me sort:updated-desc";
        }
      ];

      keybindings.prs = [
        {
          key = "T";
          name = "review in tuicr";
          command = "cd {{.RepoPath}} && ${tuicrPackage}/bin/tuicr pr {{.PrNumber}}";
        }
      ];
    };
  };
}
