# nixos

System layer (flake). See top-level `README.md` for layout and daily use; this file is bootstrap-only.

## First install (from NixOS ISO)

```sh
# 1. Network + experimental features
iwctl station wlan0 connect <SSID>

# 2. Partition + format with disko
sudo nix --extra-experimental-features 'nix-command flakes' run \
  github:nix-community/disko -- \
  --mode disko ./profiles/x86_64.nix

# 3. Pull encrypted secrets repo (private)
cd /etc && git clone git@github.com:NelsonJeppesen/secrets.git

# 4. Drop this repo onto /mnt and link
sudo cp -r /path/to/nix-lifestyle /mnt/
sudo mkdir -p /mnt/etc
sudo ln -sf /mnt/nix-lifestyle/nixos /mnt/etc/nixos

# 5. Install for a host that exists in nixos/flake.nix
sudo nixos-install --flake /mnt/etc/nixos#lg-gram-pro-17-2025
```

## Rebuild

```sh
sudo nixos-rebuild switch --flake /etc/nixos          # host inferred from $HOSTNAME
sudo nixos-rebuild switch --flake /etc/nixos#<other>  # explicit host
```

## TPM auto-unlock (LUKS)

`profiles/x86_64.nix` already sets `crypttabExtraOpts = [ "tpm2-device=auto" ]`,
but the TPM keyslot must be enrolled imperatively (per-device state, not config).
Run once per machine; re-run after BIOS/Secure Boot changes:

```sh
sudo systemd-cryptenroll /dev/nvme0n1p2                                  # list keyslots
systemd-cryptenroll --tpm2-device=list                                    # confirm TPM present
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 /dev/nvme0n1p2 # enroll (prompts for passphrase)
sudo reboot                                                               # verify silent unlock
```

Keep the passphrase keyslot as recovery. Remove TPM slot with
`sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/nvme0n1p2`.
