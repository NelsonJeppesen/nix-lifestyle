{ config, pkgs, ... }:
{
  age.secrets.s3fs-creds.file = /etc/secrets/encrypted/s3fs.creds.age;
  environment.systemPackages = with pkgs; [ s3fs ];

  fileSystems."/s3fs" = {
    device = "jeppesen.io-s3fs";
    fsType = "fuse./run/current-system/sw/bin/s3fs";
    noCheck = true;
    options = [
      "_netdev"
      "rw"
      "allow_other"
      "url=https://s3.us-west-2.amazonaws.com"
      "use_path_request_style"
      "use_cache=/var/cache/s3fs"
      "passwd_file=${config.age.secrets.s3fs-creds.path}"
    ];
  };
}
