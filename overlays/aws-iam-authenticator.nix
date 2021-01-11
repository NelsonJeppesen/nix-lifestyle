self: super: {

  aws-iam-authenticator = super.aws-iam-authenticator.overrideAttrs (oldAttrs: {
    
    version = "master";
    src = builtins.fetchGit {
      url = https://github.com/kubernetes-sigs/aws-iam-authenticator.git;
    };

  });

}
