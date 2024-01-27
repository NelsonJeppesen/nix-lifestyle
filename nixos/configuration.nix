{ lib, ... }:
let
  # read the computer serial number to index in the hostnameSet variable
  hostname = hostnameSet.${lib.removeSuffix "\n" (builtins.readFile /sys/class/dmi/id/board_serial)};

  # map serial to hostname
  hostnameSet = {
    "A0D62C851DEF02CBA03BAF34FE26013F14Z90Q-K.ARW5U1" = "gram14";
    "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-x.xxxxxx" = "gram17";
  };
in
{
  networking.hostName = hostname;

  imports = [
    ./machines/${hostname}.nix # map hostname to nix import
  ];
}
