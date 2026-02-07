{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.vscode = {
      enable = true;
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
    ];
  };
}
