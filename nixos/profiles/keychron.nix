# Give the active local desktop user access to the Keychron B1 Pro.
# uaccess grants a seat-scoped ACL instead of making every HID device writable.
{ pkgs, ... }:
{
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/70-keychron.rules" ''
      # Keychron B1 Pro: WebHID and USB access for the active desktop user.
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="071a", TAG+="uaccess"
      SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="3434", ATTR{idProduct}=="071a", TAG+="uaccess"
    '')
  ];
}
