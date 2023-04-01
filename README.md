# Living the nix[os] lifestyle

### structure
* **nixos** system NixOS (system) configuration
* **home-manager** home-manager (user) configuration

### ./nixos/
#### luks encrypted nixos
```
# Create a GPT partition table.
parted /dev/nvme0n1 -- mklabel gpt

# Create 1GiB boot partition
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1Gib
parted /dev/nvme0n1 -- set 3 esp on

# Create NixOS partition
parted /dev/nvme0n1 -- mkpart primary 1Gib -64Gib

# Leave 64Gib at the end of the drive for whatever
parted /dev/nvme0n1 -- mkpart primary -64GiB 100%

# format boot/EFI partition
mkfs.fat -F 32 -n boot /dev/nvme0n1p1

# encrypt nisos partition with luks
cryptsetup luksFormat /dev/nvme0n1p2

# open encrypted nios partition
cryptsetup luksOpen /dev/nvme0n1p2 luks

# butter format
mkfs.btrfs -L nixos /dev/mapper/luks

# mount
mount /dev/disk/by-label/nixos /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```
```
sudo ln -s nixos /etc/nixos
# create symlink for this host
ln -s nixos/machines/gram14.nix nixos/configuration.nix
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
