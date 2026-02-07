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
in
{
  disko.devices = {
    # Tmpfs root — ephemeral, wiped on every reboot
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "defaults"
        "size=2G"
        "mode=755"
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

      # Projects Drive (1TB NVMe) - BTRFS
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
                };
              };
            };
          };
        };
      };

      # Games Drive (2TB NVMe) - XFS
      games = {
        type = "disk";
        device = cfg.games;
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountpoint = "/games";
                mountOptions = [
                  "defaults"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
}
