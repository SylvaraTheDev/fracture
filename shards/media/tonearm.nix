{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  services.flatpak.packages = [
    "dev.dergs.Tonearm"
  ];

  home-manager.users.${login} = _: {
    home.persistence."/persist".directories = [
      ".var/app/dev.dergs.Tonearm"
    ];
  };
}
