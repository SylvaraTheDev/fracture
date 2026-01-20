let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  importers = import ./lib/importers.nix { inherit lib; };
in
importers.findModules ./shards
