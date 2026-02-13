{
  pkgs,
  __isDevShell ? false,
  ...
}:
if __isDevShell then
  {
    languages.dart.enable = true;
    packages = [ pkgs.flutter ];
    enterShell = ''
      echo "Dart/Flutter development shell"
      dart --version
    '';
  }
else
  { }
