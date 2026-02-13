{
  pkgs,
  __isDevShell ? false,
  ...
}:
if __isDevShell then
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
else
  { }
