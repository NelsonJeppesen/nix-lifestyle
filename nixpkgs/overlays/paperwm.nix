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
                    owner = "paperwm";
                    repo = "PaperWM";
                    rev = "e9f714846b9eac8bdd5b33c3d33f1a9d2fbdecd4";
                    sha256 = "0wdigmlw4nlm9i4vr24kvhpdbgc6381j6y9nrwgy82mygkcx55l1";
                  };
                  patches = old.patches ++ [
                    ../patches/paperwm.patch
                    ../patches/paperwm2.patch
                  ];
                });
              };
            })
