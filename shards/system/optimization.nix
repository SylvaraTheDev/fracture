{ lib, ... }:

{
  # === Boot Optimizations ===

  systemd = {
    # Don't run tmpfiles-clean at boot (too slow)
    services.systemd-tmpfiles-clean.wantedBy = lib.mkForce [ ];

    # But make the timer smarter: run weekly, catch up if system was off
    timers.systemd-tmpfiles-clean = {
      timerConfig = {
        OnCalendar = lib.mkForce "weekly";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };

    # Speed up systemd timeout for failing services
    settings.Manager = {
      DefaultTimeoutStartSec = "30s";
      DefaultTimeoutStopSec = "15s";
    };
  };

  # Reduce journal size
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
  '';

  # === CPU Performance ===

  powerManagement.cpuFreqGovernor = "performance";

  # === Kernel Sysctl Tuning ===

  boot.kernel.sysctl = {
    # Scheduling
    "kernel.sched_autogroup_enabled" = 0;
    "kernel.nmi_watchdog" = 0;
    "kernel.split_lock_mitigate" = 0;

    # Memory — reduce stutter from allocation pressure and writeback
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_ratio" = 40;
    "vm.dirty_background_ratio" = 10;
    "vm.dirty_expire_centisecs" = 3000;
    "vm.dirty_writeback_centisecs" = 1500;
    "vm.page-cluster" = 0;
    "vm.compaction_proactiveness" = 0;
    "vm.watermark_boost_factor" = 0;
    "vm.min_free_kbytes" = 131072;
    "vm.zone_reclaim_mode" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.max_map_count" = 2147483642;

    # Network — low-latency for online gaming
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_notsent_lowat" = 16384;
    "net.ipv4.tcp_fin_timeout" = 15;
    "net.ipv4.tcp_keepalive_time" = 300;
    "net.ipv4.tcp_mtu_probing" = 1;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.core.netdev_max_backlog" = 16384;
    "net.core.somaxconn" = 8192;
    "net.core.rmem_default" = 1048576;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_default" = 1048576;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_rmem" = "4096 1048576 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.ipv4.udp_rmem_min" = 8192;
    "net.ipv4.udp_wmem_min" = 8192;

    # Misc
    "fs.inotify.max_user_watches" = 524288;
    "fs.file-max" = 2097152;
    "kernel.unprivileged_userns_clone" = 1;
  };

  # === I/O Scheduler — ADIOS for NVMe (ships with CachyOS kernel) ===

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="adios"
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/nr_requests}="2048"
  '';

  # === IRQ Balancing ===

  services.irqbalance.enable = true;

  # === Compressed RAM Swap ===

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };

  # === Realtime Scheduling Permissions ===

  security.pam.loginLimits = [
    {
      domain = "@wheel";
      type = "-";
      item = "rtprio";
      value = "95";
    }
    {
      domain = "@wheel";
      type = "-";
      item = "nice";
      value = "-20";
    }
    {
      domain = "@wheel";
      type = "-";
      item = "memlock";
      value = "unlimited";
    }
    {
      domain = "@wheel";
      type = "-";
      item = "nofile";
      value = "1048576";
    }
  ];
}
