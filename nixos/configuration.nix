{ lib, pkgs, ... }:
let
  # read the computer serial number to index in the hostnameSet variable
  hostname = hostnameSet.${lib.removeSuffix "\n" (builtins.readFile /sys/class/dmi/id/board_serial)};

  # map serial to hostname
  hostnameSet = {
    # laptops
    "A0D62C851DEF02CBA03BAF34FE26013F14Z90Q-K.ARW5U1" = "gram14";
    "6637E90D521FA763D230F439CB4C2C2F17Z90Q-K.AAC7U1" = "gram17";

    # laptop k3s cluster
    "C02740702SAHJD41M" = "macbook12-0";
    "C0272460DKHHJ9K1C" = "macbook12-1";
    "C0284530316HJ9V14" = "macbook12-2";
  };
in
{
  networking.hostName = hostname;
  networking.domain = "home.arpa";

  imports = [
    # map host name to nix import
    ./machines/${hostname}.nix

    # default profiles
    ./profiles/agenix.nix
    ./profiles/shared.nix
  ];
}
