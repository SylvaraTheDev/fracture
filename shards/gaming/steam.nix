{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
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
