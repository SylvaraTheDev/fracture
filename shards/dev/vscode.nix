{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        brettm12345.nixfmt-vscode
        mkhl.direnv
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        elixir-lsp.vscode-elixir-ls
        golang.go
        dart-code.dart-code
        skellock.just
        haskell.haskell
        ms-python.python
        ms-toolsai.jupyter
        ms-vscode.cpptools
        esbenp.prettier-vscode
        redhat.vscode-yaml
        pkief.material-icon-theme
      ];
      profiles.default.userSettings = {
        "editor.fontFamily" = lib.mkForce "Fira Code Nerd Font, 'Fira Code', monospace";
        "editor.fontLigatures" = true;
        "window.dialogStyle" = "custom";
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "chat.mcp.gallery.enabled" = true;
        "workbench.iconTheme" = "material-icon-theme";
      };
    };

    home.persistence."/persist".directories = [
      ".config/Code"
    ];
  };
}
