{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.persistence."/persist-games".directories = [
      ".factorio"
    ];
  };
}
