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
