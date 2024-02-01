# Living the nix[os] lifestyle

### structure
* **nixos** system NixOS (system) configuration
* **home-manager** home-manager (user) configuration

### ./nixos/
#### luks encrypted nixos
```
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos;nix-channel --update
sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes github:nix-community/disko -- --mode disko  ./profiles/x86_64.nix
```

```
sudo mkdir /
sudo ln -s nixos /etc/nixos
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
ln -s ~/s/nix-lifestyle/home-manager ~/.config/home-manager

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

nix-shell '<home-manager>' -A install
```
