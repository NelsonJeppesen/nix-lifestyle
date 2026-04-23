# wifi.nix - iwd-managed Wi-Fi credentials sourced from agenix.
#
# Each network's credential file is decrypted into /run/agenix at boot,
# then iwd's ExecStartPre installs it into /var/lib/iwd/<NAME>.{8021x,psk}
# with mode 0600 so iwd will pick it up. This avoids putting plaintext
# credentials into the Nix store.
{ pkgs, ... }:

{
  age.secrets.wifi-wework.file = /etc/secrets/encrypted/wifi.wework.age;
  age.secrets.wifi-0x01.file = /etc/secrets/encrypted/wifi.0x01.age;
  age.secrets.wifi-0x02.file = /etc/secrets/encrypted/wifi.0x02.age;

  # On every iwd start, copy each decrypted secret into iwd's state dir
  # with the filename iwd expects.
  systemd.services.iwd = {
    serviceConfig = {
      ExecStartPre = [
        # Ensure directory exists
        "${pkgs.coreutils}/bin/install -d -m700 /var/lib/iwd"

        # Copy secret into place with correct mode
        "${pkgs.coreutils}/bin/install -m600 /run/agenix/wifi-wework /var/lib/iwd/WeWorkWiFi.8021x"
        "${pkgs.coreutils}/bin/install -m600 /run/agenix/wifi-0x01   /var/lib/iwd/0x01.psk"
        "${pkgs.coreutils}/bin/install -m600 /run/agenix/wifi-0x02   /var/lib/iwd/0x02.psk"
      ];
    };
  };
}
