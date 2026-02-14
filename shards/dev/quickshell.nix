{
  inputs,
  config,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
  quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
    withX11 = false;
    withI3 = false;
  };
in
{
  home-manager.users.${login} = {
    home.packages = [ quickshell ];
  };
}
