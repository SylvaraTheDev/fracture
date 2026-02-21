{
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = [
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
    ];

    home.persistence."/persist".directories = [
      ".config/Claude"
    ];
  };
}
