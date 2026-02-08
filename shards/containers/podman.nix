{ config, lib, ... }:

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
}
