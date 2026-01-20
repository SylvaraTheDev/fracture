{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
}
