_:

{
  home-manager.users.elyria = _: {
    programs.nushell.enable = true;
    programs.starship.enable = true;

    xdg.configFile = {
      "nushell/config.nu".source = ../../dotfiles/nushell/config.nu;
      "nushell/functions".source = ../../dotfiles/nushell/functions;
    };
  };
}
