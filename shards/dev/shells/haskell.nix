{
  pkgs,
  __isDevShell ? false,
  ...
}:
if __isDevShell then
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
else
  { }
