{ config, lib, ... }:

let
  inherit (config.fracture.user) login;
in
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "overlay2";
    enableNvidia = lib.mkIf (config.fracture.gpu == "nvidia") true;

    rootless = {
      enable = true;
      setSocketVariable = true; # sets DOCKER_HOST for the user
    };
  };

  hardware.nvidia-container-toolkit.enable = lib.mkIf (config.fracture.gpu == "nvidia") true;

  # VM-specific settings
  virtualisation.vmVariant = {
    hardware.nvidia-container-toolkit.enable = lib.mkForce false;
    virtualisation = {
      diskSize = 8192; # 8GB
      memorySize = 4096; # 4GB RAM
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/docker"
  ];

  home-manager.users.${login} = _: {
    home.persistence."/persist".directories = [
      ".local/share/docker"
    ];
  };

  users.users.${login}.extraGroups = [ "docker" ];
}
