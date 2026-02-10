_:

{
  # Disable power saving on Intel HDA (prevents audio crackling)
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
  '';

  # Realtime scheduling for PipeWire
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Low-latency gaming audio (~10.7ms at 512/48000)
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 512;
        "default.clock.min-quantum" = 256;
        "default.clock.max-quantum" = 1024;
      };
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  environment.persistence."/persist".directories = [
    "/var/lib/bluetooth"
  ];
}
