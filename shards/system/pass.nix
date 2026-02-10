{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  home-manager.users.${login} = _: {
    programs.password-store.enable = true;
    services.pass-secret-service.enable = true;

    home.persistence."/persist".directories = [
      {
        directory = ".gnupg";
        mode = "0700";
      }
      ".password-store"
    ];
  };
}
