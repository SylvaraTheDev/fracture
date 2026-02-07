{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gamescope
    protonup-qt
    winetricks
    protontricks
    r2modman
  ];

  home-manager.users.${config.fracture.user.login} = _: {
    home.packages = with pkgs; [
      parsec-bin
      bottles
    ];
  };
}
