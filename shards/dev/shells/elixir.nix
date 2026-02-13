{
  __isDevShell ? false,
  ...
}:
if __isDevShell then
  {
    languages.elixir.enable = true;
    languages.erlang.enable = true;
    enterShell = ''
      echo "Elixir development shell"
      elixir --version
    '';
  }
else
  { }
