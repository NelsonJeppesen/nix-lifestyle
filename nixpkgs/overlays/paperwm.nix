self: super: {
  gnomeExtensions = super.gnomeExtensions // {
    paperwm = super.gnomeExtensions.paperwm.overrideDerivation (old: {
      version = "pre-40.0";
      src = builtins.fetchGit {
        url = https://github.com/paperwm/paperwm.git;
        ref = "next-release";
      };
    });
  };
}
