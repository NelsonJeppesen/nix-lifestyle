{ pkgs, ... }:

{
  age.secrets.wifi-wework.file = /etc/secrets/encrypted/wifi.wework.age;
  age.secrets.wifi-0x01.file = /etc/secrets/encrypted/wifi.0x01.age;
  age.secrets.wifi-0x02.file = /etc/secrets/encrypted/wifi.0x02.age;

  # 2) On every iwd start, recreate /var/lib/iwd/WeWorkWiFi.8021x from the secret
  systemd.services.iwd = {
    # Keep existing settings, just extend serviceConfig
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
