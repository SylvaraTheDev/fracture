{ inputs, pkgs }:
config:
inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    {
      devenv.root = "/home/aeon/git/sylvara/fracture";
    }
    config
  ];
}
