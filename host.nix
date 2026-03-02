{
  fracture = {
    hostname = "fracture";
    stateVersion = "25.11";

    user = {
      login = "elyria";
      name = "Elyria";
      git = {
        name = "SylvaraTheDev";
        email = "wing@elyria.dev";
      };
      groups = [
        "networkmanager"
        "wheel"
        "video"
        "input"
        "docker"
        "kvm"
      ];
    };

    timezone = "Australia/Brisbane";
    locale = "en_AU.UTF-8";
    gpu = "nvidia";

    disks = {
      boot = "/dev/disk/by-id/REPLACE-WITH-BOOT-NVME-ID";
      projects = "/dev/disk/by-id/REPLACE-WITH-PROJECTS-NVME-ID";
      games = "/dev/disk/by-id/REPLACE-WITH-GAMES-NVME-ID";
      swapSize = "32G";
    };

    obsidian.vaults = {
      sola = {
        name = "Sola";
      };
    };

    rclone.b2.jobs = { };

    vm = {
      enable = false;
      waylandDisplay = "wayland-1";
    };
  };
}
