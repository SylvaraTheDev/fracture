{ config, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  home-manager.users.${config.fracture.user.login} = _: {
    home.persistence."/persist".directories = [
      ".local/share/Steam"
    ];
  };
}
