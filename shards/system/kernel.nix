{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  boot.kernelPackages =
    pkgs.linuxPackagesFor
      inputs.nix-cachyos-kernel.packages.${pkgs.stdenv.hostPlatform.system}.linux-cachyos-latest;

  # Serial console for VM access
  boot.kernelParams = lib.optionals config.fracture.vm.enable [ "console=ttyS0" ];

  # Scx (Scheduler)
  services.scx.enable = true;
  services.scx.scheduler = "scx_rusty";
}
