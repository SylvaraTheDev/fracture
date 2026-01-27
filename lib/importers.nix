{ lib, ... }:
let
  findModules =
    dir:
    let
      entries = builtins.readDir dir;
      processEntry =
        name: type:
        let
          path = dir + "/${name}";
        in
        if type == "directory" then
          findModules path
        else if type == "regular" && lib.strings.hasSuffix ".nix" name then
          [ path ]
        else
          [ ];
    in
    lib.lists.flatten (lib.mapAttrsToList processEntry entries);

  # Import shell definitions from a directory
  # Each .nix file becomes a devenv shell named after the file (without .nix)
  # Excludes shells.nix (the main module file)
  importShells =
    dir:
    let
      entries = builtins.readDir dir;
      processEntry =
        name: type:
        let
          shellName = lib.strings.removeSuffix ".nix" name;
        in
        if type == "regular" && lib.strings.hasSuffix ".nix" name && name != "shells.nix" then
          { ${shellName} = import (dir + "/${name}"); }
        else
          { };
    in
    lib.foldl' lib.recursiveUpdate { } (lib.mapAttrsToList processEntry entries);
in
{
  inherit findModules importShells;
}
