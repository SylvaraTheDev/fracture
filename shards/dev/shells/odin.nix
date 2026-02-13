{
  pkgs,
  __isDevShell ? false,
  ...
}:
if __isDevShell then
  {
    packages = with pkgs; [
      odin
      ols
    ];
    enterShell = ''
      echo "Odin development shell"
      odin version
    '';
  }
else
  { }
