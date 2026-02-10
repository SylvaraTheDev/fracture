{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Persist KeePassXC database and settings
  home-manager.users.${login} = _: {
    home.persistence."/persist".directories = [
      ".config/keepassxc"
      ".local/share/keepassxc"
    ];
  };
}
