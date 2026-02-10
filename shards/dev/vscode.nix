{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        mkhl.direnv
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        elixir-lsp.vscode-elixir-ls
        golang.go
        dart-code.dart-code
        nefrob.vscode-just-syntax
        haskell.haskell
        ms-python.python
        ms-toolsai.jupyter
        ms-vscode.cpptools
        esbenp.prettier-vscode
        redhat.vscode-yaml
        pkief.material-icon-theme
      ];
      profiles.default.userSettings = {
        "editor.fontFamily" = "Fira Code Nerd Font, 'Fira Code', monospace";
        "editor.fontLigatures" = true;
        "window.dialogStyle" = "custom";
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "explorer.confirmDelete" = false;
      };
    };

    home.persistence."/persist".directories = [
      ".config/Code"
      ".vscode"
    ];
  };
}
