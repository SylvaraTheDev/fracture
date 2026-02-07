{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lutris
  ];

  home-manager.users.${config.fracture.user.login} = _: {
    home.persistence."/persist".directories = [
      ".local/share/lutris"
    ];
  };
}
