{ lib, ... }:

{
  # === Boot Optimizations ===

  # Don't run tmpfiles-clean at boot (too slow)
  systemd.services.systemd-tmpfiles-clean.wantedBy = lib.mkForce [ ];

  # But make the timer smarter: run weekly, catch up if system was off
  systemd.timers.systemd-tmpfiles-clean = {
    timerConfig = {
      OnCalendar = lib.mkForce "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  # Speed up systemd timeout for failing services
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "30s";
    DefaultTimeoutStopSec = "15s";
  };

  # Reduce journal size
  services.journald.extraConfig = ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
  '';
}
