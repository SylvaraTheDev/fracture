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
      # Persist shader caches across reboots (critical for impermanence systems)
      ".cache/nvidia"
      ".cache/nv"
      ".cache/mesa_shader_cache"
      ".cache/mesa_shader_cache_db"
    ];
  };
}
