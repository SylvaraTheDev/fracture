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
        "podman"
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

    rclone.b2.jobs = {
      openclaw = {
        source = "/projects/openclaw/workspace";
        bucket = "openclaw-sola";
        dest = "openclaw/workspace";
        excludes = [ ".git/**" ];
      };

      # One-time archive of /flame/ai before drive decommission
      # Run manually: systemctl start rclone-b2-flame-archive
      # Remove this job after migration is confirmed
      flame-archive = {
        source = "/flame/ai";
        bucket = "openclaw-sola";
        dest = "archive/flame-ai";
        schedule = "2099-01-01";
      };
    };

    vm = {
      enable = true;
      waylandDisplay = "wayland-1";
    };
  };
}
