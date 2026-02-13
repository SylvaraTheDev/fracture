{ pkgs }:
{
  languages.python = {
    enable = true;
    venv.enable = true;
  };
  packages = [ pkgs.pyright ];
  enterShell = ''
    echo "Python development shell"
    python --version
  '';
}
