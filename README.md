# Living the nix[os] lifestyle

### structure
* **nixos** system NixOS configuration
* **nixpkgs** home-manager configuration

### ./nixos/
```
sudo ln -s nixos /etc/nixos
create symlink for this host 
ln -s nixos/pink.nix nixos/configuration.nix
sudo nixos-rebuilt swich --upgrade
```

### nixpkgs
home-manager
```
# Clone repo into source dir
mkdir -p ~/s
cd ~/s
git clone git@github.com:NelsonJeppesen/nix-lifestyle.git

mkdir -p ~/.config
ln -s ~/s/nix-lifestyle/nixpkgs ~/.config/nixpkgs

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
```
