{ pkgs, ... }:

{
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  # Proton / Wine / DXVK / VKD3D environment variables
  environment.variables = {
    # NTSYNC — kernel-native NT synchronization (40-200% in CPU-bound games)
    # Requires kernel 6.14+ (CachyOS 6.18 has this)
    PROTON_USE_NTSYNC = "1";

    # Native Wayland rendering — better latency and frame pacing vs XWayland
    PROTON_ENABLE_WAYLAND = "1";

    # NVIDIA DLSS / NVAPI support in Proton
    PROTON_ENABLE_NVAPI = "1";
    PROTON_DLSS_UPGRADE = "1";
    PROTON_HIDE_NVIDIA_GPU = "0";

    # FSR upscaling for all Wine/Proton games
    WINE_FULLSCREEN_FSR = "1";
    WINE_FULLSCREEN_FSR_STRENGTH = "2";

    # Wine shared memory performance
    STAGING_SHARED_MEMORY = "1";

    # DXVK — disable debug logging for performance
    DXVK_STATE_CACHE = "1";
    DXVK_LOG_LEVEL = "none";

    # VKD3D-Proton — enable DXR raytracing, disable debug logging
    VKD3D_CONFIG = "dxr11,dxr";
    VKD3D_DEBUG = "none";

    # Shader cache size
    MESA_SHADER_CACHE_MAX_SIZE = "10G";
  };

}
