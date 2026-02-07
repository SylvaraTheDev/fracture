{
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.deckmaster ];

  home-manager.users.${config.fracture.user.login} = _: {
    xdg.configFile."deckmaster".source = ../../dotfiles/deckmaster;

    systemd.user.services.deckmaster = {
      Unit = {
        Description = "Deckmaster Stream Deck Controller";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.deckmaster}/bin/deckmaster -deck %h/.config/deckmaster/main.deck";
        Restart = "always";
        RestartSec = "5";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
