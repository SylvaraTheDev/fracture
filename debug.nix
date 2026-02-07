let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  importers = import ./lib/importers.nix { inherit lib; };
in
importers.findModules ./shards
