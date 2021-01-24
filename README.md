# Living the nix[os] lifestyle

### ./nixos/
```
$ sudo ln -s nixos /etc/nixos
# create symlink for this host 
$ ln -s nixos/pink.nix nixos/configuration.nix
$ sudo nixos-rebuilt swich --upgrade
```

### nixpkgs
home-manager
```
$ ln -s nixpkgs ~/.config/nixpkgs
$ home-manager switch
```

### Brewfile
`brew bundle` for (mostly) GUI apps on MacOS not managed by Nix
