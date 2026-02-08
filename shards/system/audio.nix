_:

{
  # Disable power saving on Intel HDA (prevents audio crackling)
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
  '';

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  environment.persistence."/persist".directories = [
    "/var/lib/bluetooth"
  ];
}
