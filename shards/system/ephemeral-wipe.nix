{ pkgs, ... }:

{
  boot.initrd.systemd.enable = true;
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  boot.initrd.systemd.extraBin = {
    btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
  };

  boot.initrd.systemd.services.ephemeral-wipe = {
    description = "Wipe ephemeral btrfs subvolumes";
    wantedBy = [ "initrd.target" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /mnt-wipe

      # Wipe ephemeral @projects subvolume
      mount -t btrfs -o subvolid=5 /dev/disk/by-partlabel/disk-projects-main /mnt-wipe
      if [ -d /mnt-wipe/@projects ]; then
        btrfs subvolume delete /mnt-wipe/@projects
      fi
      btrfs subvolume snapshot /mnt-wipe/@projects-blank /mnt-wipe/@projects
      umount /mnt-wipe

      # Wipe ephemeral @games subvolume
      mount -t btrfs -o subvolid=5 /dev/disk/by-partlabel/disk-games-main /mnt-wipe
      if [ -d /mnt-wipe/@games ]; then
        btrfs subvolume delete /mnt-wipe/@games
      fi
      btrfs subvolume snapshot /mnt-wipe/@games-blank /mnt-wipe/@games
      umount /mnt-wipe

      rmdir /mnt-wipe
    '';
  };
}
