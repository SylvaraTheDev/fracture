{
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.deckmaster ];

  home-manager.users.${config.fracture.user.login} = _: {
    xdg.configFile."deckmaster".source = ../../dotfiles/deckmaster;
  };
}
