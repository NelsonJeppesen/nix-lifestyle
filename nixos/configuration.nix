{ lib, ... }:
let
  hostname = hostnameSet.${lib.removeSuffix "\n" (builtins.readFile /sys/class/dmi/id/board_serial)};
  hostnameSet = {
    "A0D62C851DEF02CBA03BAF34FE26013F14Z90Q-K.ARW5U1" = "gram14";
    "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx-x.xxxxxx" = "gram17";
  };
in
{
  imports = [ ./machines/${hostname}.nix ];
  networking.hostName = hostname;
}
