{ pkgs }:
{
  languages.c.enable = true;
  packages = with pkgs; [
    clang-tools
    gdb
  ];
  enterShell = ''
    echo "C development shell"
    cc --version | head -1
  '';
}
