{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;
in
{
  # Register nushell as a valid login shell in /etc/shells
  # (required for PAM pam_shells.so to accept TTY logins)
  environment.shells = [ pkgs.nushell ];

  home-manager.users.${login} = _: {
    programs.nushell = {
      enable = true;
      extraConfig = builtins.readFile (dotfiles + "/nushell/config.nu");
    };
    programs.starship.enable = true;

    # Functions directory (not managed by nushell module)
    home.file.".config/nushell/functions" = {
      source = dotfiles + "/nushell/functions";
      recursive = true;
      force = true;
    };

    home.persistence."/persist" = {
      directories = [ ".local/share/nushell" ];
      files = [ ".config/nushell/history.sqlite3" ];
    };
  };
}
