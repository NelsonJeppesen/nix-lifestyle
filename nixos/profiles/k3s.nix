{ config, ...}:

{
  age.secrets.k3s-token.file = ../secrets/encrypted/k3s-token.age;

  services.k3s = {
    enable = true;
    role = "server";
    token = config.age.secrets.k3s-token.path;
  };
}
