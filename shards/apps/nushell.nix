_:

{
  home-manager.users.elyria = _: {
    programs.nushell = {
      enable = true;
      extraConfig = builtins.readFile ../../dotfiles/nushell/config.nu;
    };
    programs.starship.enable = true;

    # Functions directory (not managed by nushell module)
    xdg.configFile."nushell/functions".source = ../../dotfiles/nushell/functions;
  };
}
