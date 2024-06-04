# nixos

1. boot NixOS ISO
2. configure networking
3. prep system
```
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
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

```
cp -r ../../nix-lifestyle /mnt
mkdir /mnt/etc
cd /mnt/etc
ln -s ../nix-lifestyle/nixos .
nixos-rebuilt swich --upgrade
```
