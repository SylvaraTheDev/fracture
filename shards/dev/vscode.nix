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
        ms-vscode.cmake-tools
        mesonbuild.mesonbuild
        donjayamanne.githistory
        esbenp.prettier-vscode
        redhat.vscode-yaml
        danielgavin.ols
        pkief.material-icon-theme
      ];
      profiles.default.userSettings = {
        "chat.editor.fontFamily" = "FiraCode Nerd Font";
        "chat.editor.fontSize" = 16.0;
        "chat.fontFamily" = "Noto Sans";
        "chat.mcp.gallery.enabled" = true;
        "debug.console.fontFamily" = "FiraCode Nerd Font";
        "debug.console.fontSize" = 16.0;
        "editor.fontFamily" = lib.mkForce "Fira Code Nerd Font, 'Fira Code', monospace";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 16.0;
        "editor.inlayHints.fontFamily" = "FiraCode Nerd Font";
        "editor.inlineSuggest.fontFamily" = "FiraCode Nerd Font";
        "editor.minimap.sectionHeaderFontSize" = 10.285714285714286;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "markdown.preview.fontFamily" = "Noto Sans";
        "markdown.preview.fontSize" = 16.0;
        "notebook.markup.fontFamily" = "Noto Sans";
        "scm.inputFontFamily" = "FiraCode Nerd Font";
        "scm.inputFontSize" = 14.857142857142858;
        "screencastMode.fontSize" = 64.0;
        "terminal.integrated.fontSize" = 16.0;
        "window.dialogStyle" = "custom";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.startupEditor" = "none";
      };
    };

    home.persistence."/persist".directories = [
      ".config/Code"
    ];
  };
}
