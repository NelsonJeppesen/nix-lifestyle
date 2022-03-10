(self: super: {
  gnomeExtensions = super.gnomeExtensions // {
    paperwm = super.gnomeExtensions.paperwm.overrideDerivation (old: {
      version = "pre-41.0";
      src = super.fetchFromGitHub {
        owner = "PaperWM-community";
        repo = "PaperWM";
        rev = "b66aaf13e8f4cdf0e2f9078fb3e75703535b822c";
        sha256 = "6AUUu63oWxRw9Wpxe0f7xvt7iilvQfhpAB8SYG4yP8Q=";
      };
      patches = old.patches ++ [
        ../patches/paperwm.patch
      ];
    });
  };
})
