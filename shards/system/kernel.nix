{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Serial console for VM access
  boot.kernelParams = lib.optionals config.fracture.vm.enable [ "console=ttyS0" ];

  # Scx (Scheduler)
  services.scx.enable = true;
  services.scx.scheduler = "scx_rusty";
}
