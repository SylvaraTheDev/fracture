{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  # Install KeePassXC
  environment.systemPackages = with pkgs; [
    keepassxc
  ];

  # Persist KeePassXC database, settings, and password databases
  home-manager.users.${login} = _: {
    home.persistence."/persist".directories = [
      ".config/keepassxc"
      ".local/share/keepassxc"
      "Passwords"
    ];
  };
}
