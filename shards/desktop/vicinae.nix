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

      services.vicinae.enable = true;
      home.packages = [ inputs.vicinae.packages.x86_64-linux.default ];

      home.persistence."/persist".directories = [
        ".cache/vicinae"
      ];
    };
}
