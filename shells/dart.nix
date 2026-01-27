{ mkDevShell, pkgs, ... }:
mkDevShell {
  languages.dart.enable = true;
  packages = [ pkgs.flutter ];
  enterShell = ''
    echo "Dart/Flutter development shell"
    dart --version
  '';
}
