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
sudo ln -s nixos /etc/nixos
sudo nixos-rebuilt swich --upgrade
```
sudo mkdir -p /mnt/etc/nixos
