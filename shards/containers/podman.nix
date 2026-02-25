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

  home-manager.users.${login} =
    { lib, ... }:
    {
      xdg.configFile."containers/storage.conf".text = ''
        [storage]
        driver = "overlay"
        runroot = "/home/${login}/.local/share/containers/runroot"
      '';

      xdg.configFile."containers/containers.conf".text = ''
        [engine]
        image_copy_tmp_dir = "/home/${login}/.local/share/containers/tmp"

        [engine.runtimes_flags]
        crun = ["--root=/home/${login}/.local/share/containers/crun"]
      '';

      home.activation.podmanDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.local/share/containers/tmp"
        mkdir -p "$HOME/.local/share/containers/runroot"
        mkdir -p "$HOME/.local/share/containers/crun"
      '';

      # Persist rootless container storage (images, layers, build cache)
      home.persistence."/persist".directories = [
        ".local/share/containers"
      ];
    };
}
