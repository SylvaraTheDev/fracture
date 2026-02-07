{
  config,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  environment.systemPackages = with pkgs; [
    (if config.fracture.gpu == "nvidia" then zenith-nvidia else zenith)
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      chafa
      fd
      ncdu
    ];
  };
}
