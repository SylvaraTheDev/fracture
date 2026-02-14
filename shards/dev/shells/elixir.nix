_: {
  languages.elixir.enable = true;
  languages.erlang.enable = true;
  enterShell = ''
    echo "Elixir development shell"
    elixir --version
  '';
}
