{ config, lib, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  hardware.nvidia-container-toolkit.enable = lib.mkIf (config.fracture.gpu == "nvidia") true;

  # Disable nvidia-container-toolkit in VM (no real GPU available)
  virtualisation.vmVariant = {
    hardware.nvidia-container-toolkit.enable = lib.mkForce false;
  };

  environment.persistence."/persist".directories = [
    "/var/lib/containers"
  ];
}
