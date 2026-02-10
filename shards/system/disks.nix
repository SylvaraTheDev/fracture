{ config, ... }:

let
  cfg = config.fracture.disks;

  btrfsMountOpts = [
    "compress=zstd:1"
    "noatime"
    "ssd"
    "discard=async"
    "space_cache=v2"
  ];

  # Games drive: no compression, optimized for large binary assets
  gamesMountOpts = [
    "noatime"
    "ssd"
    "discard=async"
    "space_cache=v2"
    "commit=120"
  ];
in
{
  # Impermanence requires all persistence/ephemeral mounts available in initrd
  fileSystems = {
    "/persist".neededForBoot = true;
    "/nix".neededForBoot = true;
    "/var/log".neededForBoot = true;
    "/persist-projects".neededForBoot = true;
    "/persist-games".neededForBoot = true;
    "/projects".neededForBoot = true;
    "/games".neededForBoot = true;
  };

  disko.devices = {
    # Tmpfs root — ephemeral, wiped on every reboot
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "size=2G"
        "mode=755"
        "noatime"
      ];
    };

    disk = {
      # Boot Drive (1TB NVMe) - BTRFS with subvolumes + ESP
      boot = {
        type = "disk";
        device = cfg.boot;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = btrfsMountOpts;
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = btrfsMountOpts;
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = btrfsMountOpts;
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = [
                      "noatime"
                      "ssd"
                    ];
                    swap = {
                      swapfile.size = cfg.swapSize;
                    };
                  };
                };
              };
            };
          };
        };
      };

      # Projects Drive (1TB NVMe) - BTRFS (ephemeral with persistence)
      projects = {
        type = "disk";
        device = cfg.projects;
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@projects" = {
                    mountpoint = "/projects";
                    mountOptions = btrfsMountOpts;
                  };
                  "@persist-projects" = {
                    mountpoint = "/persist-projects";
                    mountOptions = btrfsMountOpts;
                  };
                };
              };
            };
          };
        };
      };

      # Games Drive (2TB NVMe) - BTRFS (ephemeral with persistence)
      games = {
        type = "disk";
        device = cfg.games;
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@games" = {
                    mountpoint = "/games";
                    mountOptions = gamesMountOpts;
                  };
                  "@persist-games" = {
                    mountpoint = "/persist-games";
                    mountOptions = gamesMountOpts;
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
