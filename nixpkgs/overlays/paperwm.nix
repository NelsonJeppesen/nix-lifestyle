(self: super: {
  gnomeExtensions = super.gnomeExtensions // {
    paperwm = super.gnomeExtensions.paperwm.overrideDerivation (old: {
      version = "pre-41.0";
      src = super.fetchFromGitHub {
        owner = "PaperWM-community";
        repo = "PaperWM";
        rev = "next-release";
        sha256 = "yjyZEL/a3D0jQQEelddWRAMaRLYrK3BapQ7x3+tzOw0=";
      };
      patches = old.patches ++ [
        ../patches/paperwm.patch
      ];
    });
  };
})
