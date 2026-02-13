{
  pkgs,
  __isDevShell ? false,
  ...
}:
if __isDevShell then
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
else
  { }
