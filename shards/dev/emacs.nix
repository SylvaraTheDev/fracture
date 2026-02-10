{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;
in
{
  home-manager.users.${login} = _: {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk.pkgs.withPackages (epkgs: [
        epkgs.use-package
        epkgs.treemacs
        epkgs.docker
        epkgs.doom-themes
        epkgs.doom-modeline
        epkgs.base16-theme
      ]);
    };

    home.file.".emacs.d" = {
      source = dotfiles + "/emacs";
      recursive = true;
      force = true;
    };

    home.persistence."/persist".directories = [
      ".config/emacs"
      ".local/share/emacs"
    ];
  };
}
