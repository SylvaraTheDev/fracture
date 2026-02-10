{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-lto-x86_64-v3;

  # Serial console for VM access
  boot.kernelParams = lib.optionals config.fracture.vm.enable [ "console=ttyS0" ];

  # Scx (Scheduler)
  services.scx.enable = true;
  services.scx.scheduler = "scx_rusty";
}
