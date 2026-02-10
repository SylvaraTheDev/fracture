{
  config,
  inputs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  # Vicinae - Wayland Launcher

  # Enable the service and package via Home Manager
  home-manager.users.${login} =
    { ... }:
    {
      imports = [ inputs.vicinae.homeManagerModules.default ];

      services.vicinae = {
        enable = true;
        systemd.enable = true;
      };

      home.persistence."/persist".directories = [
        ".cache/vicinae"
      ];
    };
}
