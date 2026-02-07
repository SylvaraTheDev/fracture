{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    heroic
  ];

  home-manager.users.${config.fracture.user.login} = _: {
    home.persistence."/persist".directories = [
      ".config/heroic"
    ];
  };
}
