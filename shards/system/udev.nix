_:

{
  services.udev.extraRules = ''
    # Finalmouse ULX - Disable Autosuspend
    # Fixes libinput bug where disconnecting the dongle causes phantom clicks until reboot
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="361d", ATTR{power/control}="on"

    # Finalmouse ULX - Permissions for XPanel
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="361d", MODE="0660", GROUP="users"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="361d", MODE="0660", GROUP="users"
  '';
}
