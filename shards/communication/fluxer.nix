{
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = [
      inputs.fluxer.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home.persistence."/persist".directories = [
      ".config/fluxer"
    ];
  };
}
