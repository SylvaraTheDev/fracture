{ config, pkgs, ... }:

{
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  home-manager.users.${config.fracture.user.login} = _: {
    home.persistence."/persist".directories = [
      ".local/share/Steam/compatibilitytools.d"
    ];
  };
}
