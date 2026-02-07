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
  sops.secrets."users/${user.login}/password" = {
    sopsFile = ../../secrets/auth/users.yaml;
    neededForUsers = true;
  };

  users.users.${user.login} = {
    isNormalUser = true;
    description = user.name;
    hashedPasswordFile = config.sops.secrets."users/${user.login}/password".path;
    extraGroups = user.groups;
    shell = pkgs.nushell;
    ignoreShellProgramCheck = true;
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

    programs.git = {
      enable = true;
      settings = {
        user.name = user.git.name;
        user.email = user.git.email;
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
