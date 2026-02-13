{ pkgs }:
{
  packages = with pkgs; [
    qt6.qtdeclarative
    qt6.qtbase
  ];
  enterShell = ''
    echo "QML development shell"
    qmlformat --version 2>/dev/null || echo "QML tools ready"
  '';
}
