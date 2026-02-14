{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.persistence."/persist-games".directories = [
    {
      directory = "/games/steam";
      user = login;
      group = "users";
      mode = "0755";
    }
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
    package = pkgs.steam.override {
      extraEnv = {
        # Gaming GL performance — scoped here instead of system-wide
        __GL_THREADED_OPTIMIZATIONS = "1";
        __GL_GSYNC_ALLOWED = "1";
        __GL_VRR_ALLOWED = "1";
        __GL_MaxFramesAllowed = "1";
        __GL_YIELD = "NOTHING";

        # Proton / Wine / DXVK / VKD3D — scoped to Steam FHS env
        PROTON_USE_NTSYNC = "1";
        PROTON_ENABLE_NVAPI = "1";
        PROTON_DLSS_UPGRADE = "1";
        PROTON_HIDE_NVIDIA_GPU = "0";
        WINE_FULLSCREEN_FSR = "1";
        WINE_FULLSCREEN_FSR_STRENGTH = "2";
        STAGING_SHARED_MEMORY = "1";
        DXVK_STATE_CACHE = "1";
        DXVK_LOG_LEVEL = "none";
        VKD3D_CONFIG = "dxr11,dxr";
        VKD3D_DEBUG = "none";
      };
      # Steam bundles its own 32-bit mesa; the global nvidia GLX vendor
      # override breaks its bundled libGL. Unset it inside the FHS env.
      extraProfile = ''
        unset __GLX_VENDOR_LIBRARY_NAME
      '';
    };
    extraPackages = with pkgs; [
      mangohud
      gamescope
    ];
  };

  home-manager.users.${login} = _: {
    home.persistence."/persist".directories = [
      ".local/share/Steam"

      # Native game data (lives outside Steam)
      ".factorio" # Factorio — saves, mods, config
      ".local/share/Paradox Interactive" # Stellaris — saves, mods, settings
      ".paradoxlauncher" # Paradox Launcher v2 — login state, settings

      # External mod managers
      ".config/r2modmanPlus-local" # R2ModMan — Risk of Rain 2 mod profiles

      # Proton titles (saves live in compatdata inside .local/share/Steam):
      # Helldivers 2, The Finals, Risk of Rain 2, Runescape,
      # Metal Hellsinger, GTFO, Elite Dangerous, Dune Awakening, Arc Raiders

      # Shader caches (critical for impermanence systems)
      ".cache/nvidia"
      ".cache/nv"
      ".cache/mesa_shader_cache"
      ".cache/mesa_shader_cache_db"
    ];
  };
}
