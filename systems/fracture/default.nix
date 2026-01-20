{
  config,
  lib,
  pkgs,
  findModules,
  ...
}:

{
  imports = [ ./hardware.nix ] ++ (findModules ../../shards); # Using our custom importer

  networking.hostName = "fracture";
  system.stateVersion = "25.11";
}
