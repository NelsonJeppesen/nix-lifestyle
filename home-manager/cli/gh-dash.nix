{ ... }:
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
    };
  };
}
