{ pkgs }:
{
  languages.haskell.enable = true;
  packages = with pkgs; [
    hlint
    ormolu
  ];
  enterShell = ''
    echo "Haskell development shell"
    ghc --version
  '';
}
