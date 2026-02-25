{
  config,
  inputs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} =
    { ... }:
    {
      imports = [ inputs.filigree.homeManagerModules.default ];

      programs.filigree = {
        enable = true;
        systemd.enable = true;
        settings = {
          bar = {
            status.showDocker = true;
            docker.url = "unix:///run/docker.sock";
            tray.excludedItems = [
              "nm-applet"
              "blueman"
            ];
          };
          background = {
            enabled = true;
            wallpaper = {
              path = "~/.config/niri/wallpapers/deltahub-white2.jpg";
              screens."DP-1" = "~/.config/niri/wallpapers/deltahub-white.jpg";
            };
          };
        };
      };
    };
}
