# s3fs.nix - Mount an AWS S3 bucket as a local filesystem via s3fs-fuse.
#
# - Bucket: jeppesen.io-s3fs in us-west-2
# - Credentials: agenix-managed at /etc/secrets/encrypted/s3fs.creds.age
# - Mounted lazily via systemd automount; idles after 10 min of inactivity
# - Page cache lives at /var/cache/s3fs (s3fs-managed)
# - allow_other lets non-root users access the mount (FUSE security boundary)
{ config, pkgs, ... }:
{
  age.secrets.s3fs-creds.file = /etc/secrets/encrypted/s3fs.creds.age;
  environment.systemPackages = with pkgs; [ s3fs ];

  fileSystems."/s3fs" = {
    device = "jeppesen.io-s3fs";
    fsType = "fuse./run/current-system/sw/bin/s3fs";
    noCheck = true;
    options = [
      # Defer mount until network-online and don't fail boot if S3 is
      # unreachable; mount lazily on first access via systemd automount.
      "_netdev"
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.requires=network-online.target"
      "x-systemd.after=network-online.target"
      "rw"
      "allow_other"
      "url=https://s3.us-west-2.amazonaws.com"
      "use_path_request_style"
      "use_cache=/var/cache/s3fs"
      "passwd_file=${config.age.secrets.s3fs-creds.path}"
    ];
  };
}
