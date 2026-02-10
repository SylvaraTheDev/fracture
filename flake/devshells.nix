_: {
  perSystem =
    { pkgs, ... }:
    {
      devenv.shells = {
        # === Nix Development Shell ===
        # Primary shell with pre-commit hooks via Prek
        nix = {
          packages = with pkgs; [
            # Pre-commit (Rust)
            prek

            # Nix LSP
            nil
            nixd

            # Secret detection
            gitleaks

            # Build tools
            just
          ];

          enterShell = ''
            if [ -d .git ]; then
              prek install --install-hooks 2>/dev/null || true
            fi
          '';
        };

        # === Language Shells ===

        python = {
          languages.python = {
            enable = true;
            venv.enable = true;
          };
          packages = [ pkgs.pyright ];
          enterShell = ''
            echo "Python development shell"
            python --version
          '';
        };

        go = {
          languages.go.enable = true;
          packages = with pkgs; [
            gopls
            golangci-lint
          ];
          enterShell = ''
            echo "Go development shell"
            go version
          '';
        };

        elixir = {
          languages.elixir.enable = true;
          languages.erlang.enable = true;
          enterShell = ''
            echo "Elixir development shell"
            elixir --version
          '';
        };

        dart = {
          languages.dart.enable = true;
          packages = [ pkgs.flutter ];
          enterShell = ''
            echo "Dart/Flutter development shell"
            dart --version
          '';
        };

        odin = {
          packages = with pkgs; [
            odin
            ols
          ];
          enterShell = ''
            echo "Odin development shell"
            odin version
          '';
        };

        packaging = {
          packages = with pkgs; [
            nix-init
            nurl
          ];
          enterShell = ''
            echo "Nix packaging shell (nix-init + nurl)"
            nix-init --version
          '';
        };

        kubernetes = {
          packages = with pkgs; [
            kubectl
            talosctl
            omnictl
            helm
          ];
          enterShell = ''
            echo "Kubernetes development shell"
            kubectl version --client --short 2>/dev/null || echo "kubectl ready"
          '';
        };
      };
    };
}
