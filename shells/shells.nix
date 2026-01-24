{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      devenv.shells = {
        elixir = {
          languages.elixir.enable = true;
          languages.erlang.enable = true;
          # TODO: Add expert LSP when packaged
          enterShell = ''
            echo "🧪 Elixir development shell"
            elixir --version
          '';
        };

        go = {
          languages.go.enable = true;
          packages = [
            pkgs.gopls
            pkgs.golangci-lint
          ];
          enterShell = ''
            echo "🐹 Go development shell"
            go version
          '';
        };

        dart = {
          languages.dart.enable = true;
          packages = [ pkgs.flutter ];
          enterShell = ''
            echo "🎯 Dart/Flutter development shell"
            dart --version
          '';
        };

        python = {
          languages.python = {
            enable = true;
            venv.enable = true;
          };
          packages = [ pkgs.pyright ];
          enterShell = ''
            echo "🐍 Python development shell"
            python --version
          '';
        };

        kubernetes = {
          packages = [
            pkgs.kubectl
            pkgs.talosctl
            pkgs.omnictl
            pkgs.helm
          ];
          enterShell = ''
            echo "☸️ Kubernetes development shell"
            kubectl version --client --short 2>/dev/null || echo "kubectl ready"
          '';
        };
      };
    };
}
