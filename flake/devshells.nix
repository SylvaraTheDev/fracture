_: {
  perSystem =
    { pkgs, lib, ... }:
    let
      shellsDir = ../shards/dev/shells;
      entries = builtins.readDir shellsDir;
      shells = lib.mapAttrs' (name: _: {
        name = lib.removeSuffix ".nix" name;
        value = import (shellsDir + "/${name}") {
          inherit pkgs;
          __isDevShell = true;
        };
      }) (lib.filterAttrs (_: type: type == "regular") entries);
    in
    {
      devenv.shells = shells;
    };
}
