#self: super: {
#  gnomeExtensions = super.gnomeExtensions // {
#    paperwm = super.gnomeExtensions.paperwm.overrideDerivation (old: {
#      version = "pre-40.0";
#      src = builtins.fetchGit {
#        url = https://github.com/paperwm/paperwm.git;
#        ref = "next-release";
#      };
#    });
#  };
#}

(self: super: {
              gnomeExtensions = super.gnomeExtensions // {
                paperwm = super.gnomeExtensions.paperwm.overrideDerivation (old: {
                  version = "pre-41.0";
                  src = super.fetchFromGitHub {
                    owner = "PaperWM-community";
                    repo = "PaperWM";
                    rev = "3e4dcd1f4506670f626cd2176979ded2757235f0";
                    sha256 = "0wdigmlw4nlm9i4vr24kvhpdbgc6381j6y9nrwgy82mygkcx55l1";
                  };
                  patches = old.patches ++ [
                    ../patches/paperwm.patch
                    ../patches/paperwm2.patch
                  ];
                });
              };
            })
