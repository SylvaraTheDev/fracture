{
  inputs,
  ...
}:

{
  # Vicinae - Wayland Launcher

  # Enable the service and package via Home Manager
  home-manager.users.elyria =
    { ... }:
    {
      imports = [ inputs.vicinae.homeManagerModules.default ];

      services.vicinae.enable = true;
      home.packages = [ inputs.vicinae.packages.x86_64-linux.default ];
    };
}
