# NixOS system layer

The flake builds two laptop configurations. `configuration.nix` supplies the
cross-host baseline, machine modules choose hardware and profiles, and profiles
contain one reusable concern. User applications and preferences live in the
independent `home-manager/` flake. See the root README for daily use.

## Review and rebuild

Run from the repository root. Dry builds evaluate the selected host and report
build/substitution work without activating the configuration or changing disks:

```sh
nixos-rebuild dry-build --flake ./nixos#lg-gram-pro-17-2025
nixos-rebuild dry-build --flake ./nixos#lg-gram-14-2022
```

To activate the installed host, use `sudo nixos-rebuild switch --flake /etc/nixos`.
Do not activate the other host's configuration on this machine. Passwordless
`nix` and `nixos-rebuild` privileges are root-equivalent; their command allowlist
does not isolate an agent or an untrusted flake from the system.

## First install from a NixOS ISO

This procedure formats the selected disk. Boot the ISO, connect networking, and
make Git, Nix, and access to the private encrypted-secrets repository available.
Clone this repository into a writable directory on the live system, enter its
root, and select the target host:

```sh
install_host=lg-gram-pro-17-2025
export NIX_CONFIG='experimental-features = nix-command flakes'
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
nix eval --raw "./nixos#nixosConfigurations.${install_host}.config.disko.devices.disk.vdb.device"
```

Match the evaluated device to the intended physical disk before proceeding.
The 2025 machine uses a verified by-id path. The 2022 machine's numeric device
name requires verification on that machine and replacement with its by-id path
before installation. NVMe enumeration order is not a stable disk identity.
When replacing hardware, update the machine's device identity first. Do not run
these steps against a mounted installation you intend to preserve.

Use the Disko input from this flake's lock file and its NixOS host configuration.
The dry run builds and prints the generated script without executing it; inspect
that script's device paths before running the destructive command:

```sh
nix run --inputs-from ./nixos disko -- \
  --dry-run --mode destroy,format,mount --flake "./nixos#${install_host}"

sudo env NIX_CONFIG="$NIX_CONFIG" nix run --inputs-from ./nixos disko -- \
  --mode destroy,format,mount --flake "./nixos#${install_host}"
```

Disko mounts the new filesystems at `/mnt`. Stage the repository, encrypted
secrets, and an authorized age decryption identity in the target system:

```sh
sudo mkdir -p /mnt/etc
sudo cp -a . /mnt/etc/nix-lifestyle
sudo ln -s nix-lifestyle/nixos /mnt/etc/nixos
sudo git clone git@github.com:NelsonJeppesen/secrets.git /mnt/etc/secrets
```

Use an authenticated clone/restore method available in the installer; `sudo git`
may require explicitly forwarded SSH authentication. Only encrypted `.age` files
belong in that repository. Incoming OpenSSH and Tailscale SSH are disabled. The host keys below are local
agenix decryption identities, not a requirement to run an SSH server. System
agenix decrypts at activation from
`/etc/secrets/encrypted/`; restore the SSH host private key authorized by those
files into `/mnt/etc/ssh/` with root ownership and mode `0600`, or generate a new
host key there and re-encrypt secrets to its public key. Do not copy a laptop's
host identity to a different laptop. Home Manager's user secrets require its
separate user identity after user setup.

```sh
sudo env NIX_CONFIG="$NIX_CONFIG" nixos-install \
  --flake "/mnt/etc/nixos#${install_host}"
```

The relative `/mnt/etc/nixos` link resolves both in the installer and after the
new system becomes `/`. The encrypted secrets and host identity must also be
present on that installed system before its first activation.

## TPM unlock and recovery

The disk layout requests `tpm2-device=auto`; it does not enroll a TPM keyslot.
On the installed host, identify the actual LUKS backing device instead of assuming
a numeric NVMe name:

```sh
findmnt -no SOURCE / /boot
sudo cryptsetup status crypted
lsblk -o NAME,PATH,TYPE,FSTYPE,MOUNTPOINTS
systemd-cryptenroll --tpm2-device=list
```

Set `luks_device` to the verified LUKS partition (prefer its by-id path), then
inspect existing slots with `sudo systemd-cryptenroll "$luks_device"`. Keep and
verify a recovery passphrase before changing enrollment. Choose a TPM policy
that matches the actual Secure Boot/measured-boot setup; PCR `0+7` alone is not a
verified kernel/initrd authenticity guarantee when Secure Boot is disabled.
Consult [systemd-cryptenroll](https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html)
for PCR and PIN policy choices. Enrollment and recovery-key changes are separate
maintenance operations, not part of ordinary `update`.

To remove TPM enrollment from the verified device while retaining the recovery
passphrase, use `sudo systemd-cryptenroll --wipe-slot=tpm2 "$luks_device"`.

## Filesystem verification

Both hosts schedule a monthly Btrfs scrub of `/`. The service starts only on AC
power and inherits idle CPU/IO scheduling plus niceness 19 from the pinned NixOS
module. A scrub reads allocated data and metadata to check checksums; it can
repair only where a valid redundant copy exists and does not replace backups.

The timer is persistent across shutdowns. If its start is skipped because the
laptop is on battery, plugging in does not automatically retry that missed run.
On AC, start a missed run and inspect results with:

```sh
sudo systemctl start btrfs-scrub@-.service
journalctl -u btrfs-scrub@-.service
sudo btrfs scrub status /
```

A failed scrub remains visible in `systemctl --failed` and the service journal.
The review/configuration change does not start a scrub or activate the timer.
