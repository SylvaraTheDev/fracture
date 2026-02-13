{ pkgs }:
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
