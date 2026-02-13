_: {
  perSystem =
    { pkgs, ... }:
    let
      lang = name: import ../shards/dev/languages/${name}.nix { inherit pkgs; };
    in
    {
      devenv.shells = {
        nix = lang "nix";
        python = lang "python";
        go = lang "go";
        elixir = lang "elixir";
        dart = lang "dart";
        c = lang "c";
        odin = lang "odin";
        haskell = lang "haskell";
        qml = lang "qml";
        packaging = lang "packaging";
        kubernetes = lang "kubernetes";
      };
    };
}
