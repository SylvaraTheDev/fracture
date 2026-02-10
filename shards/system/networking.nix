{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    firewall.enable = true;
  };

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      networkmanagerapplet
    ];
  };

  environment.persistence."/persist".directories = [
    "/etc/NetworkManager/system-connections"
  ];
}
