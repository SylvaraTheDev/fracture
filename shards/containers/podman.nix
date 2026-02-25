{ config, lib, ... }:

let
  inherit (config.fracture.user) login;
in
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
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
    "/var/lib/containers"
  ];

  home-manager.users.${login} = _: {
    xdg.configFile."containers/storage.conf".text = ''
      [storage]
      driver = "overlay"
    '';

    # Persist rootless container storage (images, layers, build cache)
    home.persistence."/persist".directories = [
      ".local/share/containers"
    ];
  };
}
