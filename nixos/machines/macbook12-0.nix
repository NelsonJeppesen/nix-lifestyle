# Apple MacBook 12
#
# The most cute server in the world
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }: {
  system.stateVersion = "24.11";

  imports = [
    # secrets
    # standard stuff
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix

    # lets make this a k3s server
    # ../profiles/k3s.nix
    ../profiles/macbook12-server.nix
    ../profiles/macbook12.nix
  ];

  # this is the first node of the k3s cluster
  # services.k3s.clusterInit = true;

  services.atuin.enable = true;
  services.atuin.host = "0.0.0.0";
  services.atuin.openRegistration = true;
  services.atuin.openFirewall = true;

  # WireGuard VPN Server
  networking.nat = {
    enable = true;
    externalInterface = "wlan0";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    extraCommands = ''
      iptables -A INPUT -i wg0 -p tcp --dport 22 -j ACCEPT
      iptables -A INPUT -i wg0 -p icmp -j ACCEPT
    '';
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.100.0.1/24" ];
    listenPort = 51820;
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o wlan0 -j MASQUERADE
    '';
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o wlan0 -j MASQUERADE
    '';
    privateKey = "SCys2wjN8CVjxhm7lb1ljR9DfFd/WksDYOpaN9TCW2k=";
    peers = [
      {
        # Linux/Desktop client
        publicKey = "8V7C12fYe8IrnI3yr8cwmzVpUwVCjoMIfUuAm1b08mw=";
        allowedIPs = [ "10.100.0.0/24" ];
      }
      {
        # Android client
        publicKey = "hGekgqLZPWbKf7M0Hf/jKehdPAVcC6LH847vtWYWCQA=";
        allowedIPs = [ "10.100.0.0/24" ];
      }
    ];
  };

  # Route53 DNS updater (hourly)
  systemd.services.route53-dns-update = {
    description = "Update Route53 DNS with current public IP";
    path = [ pkgs.curl pkgs.awscli2 pkgs.jq ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      set -euo pipefail

      PUBLIC_IP=$(curl -s https://api.ipify.org)
      
      if [ -f /root/route53-config ]; then
        source /root/route53-config
      else
        echo "Error: /root/route53-config not found"
        exit 1
      fi

      CHANGE_BATCH=$(cat <<EOF
      {
        "Changes": [{
          "Action": "UPSERT",
          "ResourceRecordSet": {
            "Name": "$ROUTE53_RECORD_NAME",
            "Type": "A",
            "TTL": 300,
            "ResourceRecords": [{"Value": "$PUBLIC_IP"}]
          }
        }]
      }
      EOF
      )

      aws route53 change-resource-record-sets \
        --hosted-zone-id "$ROUTE53_ZONE_ID" \
        --change-batch "$CHANGE_BATCH"

      echo "Updated $ROUTE53_RECORD_NAME to $PUBLIC_IP"
    '';
  };

  systemd.timers.route53-dns-update = {
    description = "Hourly Route53 DNS update timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "1h";
      Unit = "route53-dns-update.service";
    };
  };
}
