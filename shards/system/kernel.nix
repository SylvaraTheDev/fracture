{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

  boot.kernelParams = [
    # Security mitigations off (gaming desktop, not a multi-user server)
    "mitigations=off"

    # Timer / Clock — TSC is lowest-latency on modern AMD Zen
    "tsc=reliable"
    "clocksource=tsc"

    # Watchdog off — saves CPU cycles from periodic NMI interrupts
    "nowatchdog"
    "nmi_watchdog=0"

    # Full preemption for lowest scheduling latency
    "preempt=full"

    # Transparent hugepages for gaming workloads
    "transparent_hugepage=always"

    # AMD CPU — P-State active mode, limit C-states for responsiveness
    "amd_pstate=active"
    "processor.max_cstate=1"
    "idle=nomwait"

    # NVMe power saving off — keep drives at full speed
    "nvme_core.default_ps_max_latency_us=0"

    # Disable split lock detection — Proton games trigger these constantly
    "split_lock_detect=off"

    # Disable kernel auditing and reduce log noise
    "audit=0"
    "loglevel=3"

    # Maximize PCIe bandwidth
    "pci=pcie_bus_perf"
  ]
  ++ lib.optionals config.fracture.vm.enable [ "console=ttyS0" ];

  # BBR TCP congestion control module
  boot.kernelModules = [ "tcp_bbr" ];

  # Blacklist watchdog modules (AMD)
  boot.blacklistedKernelModules = [
    "sp5100_tco"
    "iTCO_wdt"
  ];

  # scx_lavd — latency-critical virtual deadline scheduler (developed for Valve/Steam Deck)
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
  services.scx.extraArgs = [ "--performance" ];
}
