{
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.deckmaster ];

  home-manager.users.elyria = _: {
    xdg.configFile."deckmaster".source = ../../dotfiles/deckmaster;
  };
}
