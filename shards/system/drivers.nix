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
        vulkan-loader
      ]
    );
    extraPackages32 = lib.mkIf (config.fracture.gpu == "nvidia") (
      with pkgs.pkgsi686Linux;
      [
        vulkan-loader
      ]
    );
  };

  # NVIDIA
  services.xserver.videoDrivers = lib.mkIf (config.fracture.gpu == "nvidia") [ "nvidia" ];
  hardware.nvidia = lib.mkIf (config.fracture.gpu == "nvidia") {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    persistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # NVIDIA kernel params
  boot.kernelParams = lib.mkIf (config.fracture.gpu == "nvidia") [
    "nvidia_drm.modeset=1"
    "nvidia_drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    "nvidia.NVreg_UsePageAttributeTable=1"
    "nvidia.NVreg_InitializeSystemMemoryAllocations=0"
  ];

  # NVIDIA modprobe — disable dynamic power management on desktop
  boot.extraModprobeConfig = lib.mkIf (config.fracture.gpu == "nvidia") ''
    options nvidia NVreg_DynamicPowerManagement=0x00
  '';

  # NVIDIA + Wayland environment variables
  environment.variables = lib.mkIf (config.fracture.gpu == "nvidia") {
    # Wayland / Desktop
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";

    # OpenGL performance
    __GL_THREADED_OPTIMIZATIONS = "1";
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    __GL_MaxFramesAllowed = "1";
    __GL_YIELD = "NOTHING";

    # Shader cache — persist on fast storage, never auto-clean
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_SHADER_DISK_CACHE_SIZE = "10000000000";
  };
}
