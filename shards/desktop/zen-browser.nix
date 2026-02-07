{ config, inputs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} =
    { ... }:
    {
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser.enable = true;

      home.persistence."/persist".directories = [
        ".zen"
      ];
    };
}
