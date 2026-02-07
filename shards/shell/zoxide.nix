{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };

    home.persistence."/persist".directories = [
      ".local/share/zoxide"
    ];
  };
}
