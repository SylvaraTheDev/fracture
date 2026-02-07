{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    podman-tui
    podman-compose
    podman-desktop
  ];
}
