{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = lib.mkIf (config.fracture.gpu == "nvidia") (
      with pkgs;
      [
        nvidia-vaapi-driver
        libva
        libva-utils
      ]
    );
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

  # NVIDIA kernel params
  boot.kernelParams = lib.mkIf (config.fracture.gpu == "nvidia") [
    "nvidia_drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];

  # NVIDIA + Electron/Wayland environment variables
  environment.variables = lib.mkIf (config.fracture.gpu == "nvidia") {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_THREADED_OPTIMIZATIONS = "0";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";
  };
}
