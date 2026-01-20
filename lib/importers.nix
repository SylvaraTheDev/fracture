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
in
{
  inherit findModules;
}
