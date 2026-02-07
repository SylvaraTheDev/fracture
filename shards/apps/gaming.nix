{ config, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  programs.gamemode.enable = true;

  # Persist Steam config/login state; add /games as a library folder via Steam UI
  home-manager.users.${config.fracture.user.login} = _: {
    home.persistence."/persist".directories = [
      ".local/share/Steam"
    ];
  };
}
