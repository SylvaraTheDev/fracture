{ mkDevShell, pkgs, ... }:
mkDevShell {
  languages.go.enable = true;
  packages = [
    pkgs.gopls
    pkgs.golangci-lint
  ];
  enterShell = ''
    echo "Go development shell"
    go version
  '';
}
