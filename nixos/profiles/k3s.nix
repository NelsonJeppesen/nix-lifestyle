{ config, ...}:

{
  age.secrets.k3s-token.file = /etc/secrets/encrypted/k3s-token.age;

  networking.firewall.enable = false;

  services.k3s = {
    enable = true;
    role = "server";
    token = config.age.secrets.k3s-token.path;
  };
}
