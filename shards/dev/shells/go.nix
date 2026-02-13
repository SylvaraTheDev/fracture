{ pkgs }:
{
  languages.go.enable = true;
  packages = with pkgs; [
    gopls
    golangci-lint
  ];
  enterShell = ''
    echo "Go development shell"
    go version
  '';
}
