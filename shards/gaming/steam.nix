{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.persistence."/persist-games".directories = [
    "/games/steam"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  home-manager.users.${login} = _: {
    home.persistence."/persist".directories = [
      ".local/share/Steam"
    ];
  };
}
