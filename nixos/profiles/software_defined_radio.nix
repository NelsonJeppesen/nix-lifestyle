# software_defined_radio.nix - RTL-SDR USB dongle support + SDR++ GUI
{ pkgs, lib, ... }:

{
  hardware.rtl-sdr.enable = lib.mkDefault true;
  environment.systemPackages = with pkgs; [ sdrpp ];
}
