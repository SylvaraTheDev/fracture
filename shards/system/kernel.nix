{
  config,
  pkgs,
  inputs,
  ...
}:

{
  boot.kernelPackages =
    pkgs.linuxPackagesFor
      inputs.nix-cachyos-kernel.packages.${pkgs.system}.linux-cachyos-latest;

  # Serial console for VM access
  boot.kernelParams = [ "console=ttyS0" ];

  # Scx (Scheduler)
  services.scx.enable = true;
  services.scx.scheduler = "scx_rusty";
}
