{ config, lib, ... }:

{
  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA
  services.xserver.videoDrivers = lib.mkIf (config.fracture.gpu == "nvidia") [ "nvidia" ];
  hardware.nvidia = lib.mkIf (config.fracture.gpu == "nvidia") {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
