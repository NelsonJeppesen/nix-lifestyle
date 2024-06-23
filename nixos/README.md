# nixos

1. boot NixOS ISO
2. configure networking
3. prep system
```
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
sudo nix-channel --add https://github.com/ryantm/agenix/archive/main.tar.gz agenix
sudo nix-channel --update
```

4. format and mount disks
```
sudo nix run \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes      \
  github:nix-community/disko                \
  -- --mode disko  ./profiles/x86_64.nix
```

5. download `nixage` secrets
```
cd /etc
git clone git@github.com:NelsonJeppesen/secrets.git
```

```
sudo cp -r ../../nix-lifestyle /mnt
sudo mkdir /mnt/etc
sudo cd /mnt/etc
sudo ln -s ../nix-lifestyle/nixos .
sudo nixos-install --upgrade
```
