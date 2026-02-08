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
    xdg.enable = true;

    home.persistence."/persist" = {
      directories = [
        ".local/share/nix"
        ".config/sops"
      ];
    };
  };
}
