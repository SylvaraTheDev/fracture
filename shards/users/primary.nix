{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture) user;
in
{
  sops.secrets."users/${user.login}/password" = lib.mkIf (!config.fracture.vm.enable) {
    sopsFile = config.fracture.secretsDir + "/auth/users.yaml";
    neededForUsers = true;
  };

  users.users.${user.login} = {
    isNormalUser = true;
    description = user.name;
    extraGroups = user.groups;
    shell = pkgs.nushell;
    ignoreShellProgramCheck = true;
  }
  // lib.optionalAttrs config.fracture.vm.enable {
    initialPassword = "1142";
  }
  // lib.optionalAttrs (!config.fracture.vm.enable) {
    hashedPasswordFile = config.sops.secrets."users/${user.login}/password".path;
  };

  home-manager.users.${user.login} = _: {
    home = {
      inherit (config.fracture) stateVersion;
      username = user.login;
      homeDirectory = "/home/${user.login}";
      sessionVariables = {
        XDG_DATA_DIRS = "$HOME/.nix-profile/share:$XDG_DATA_DIRS";
      }
      // lib.optionalAttrs config.fracture.vm.enable {
        # For synced terminal/GUI in VM - connect to Niri Wayland session
        WAYLAND_DISPLAY = config.fracture.vm.waylandDisplay;
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
    };

    # XDG
    xdg = {
      enable = true;

      desktopEntries.emacs = {
        name = "Emacs";
        genericName = "Text Editor";
        comment = "Edit text";
        exec = "emacs %F";
        icon = "emacs";
        type = "Application";
        terminal = false;
        categories = [
          "Development"
          "TextEditor"
          "Utility"
        ];
        mimeType = [
          "text/english"
          "text/plain"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-python"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
        ];
      };

      mimeApps = {
        enable = true;
        defaultApplications = {
          "x-scheme-handler/http" = [ "zen-twilight.desktop" ];
          "x-scheme-handler/https" = [ "zen-twilight.desktop" ];
          "x-scheme-handler/chrome" = [ "zen-twilight.desktop" ];
          "text/html" = [ "zen-twilight.desktop" ];
          "application/x-extension-htm" = [ "zen-twilight.desktop" ];
          "application/x-extension-html" = [ "zen-twilight.desktop" ];
          "application/x-extension-shtml" = [ "zen-twilight.desktop" ];
          "application/xhtml+xml" = [ "zen-twilight.desktop" ];
          "application/x-extension-xhtml" = [ "zen-twilight.desktop" ];
          "application/x-extension-xht" = [ "zen-twilight.desktop" ];
        };
      };
    };

    home.persistence."/persist" = {
      directories = [
        ".local/share/nix"
        ".config/sops"
      ];
    };
  };
}
