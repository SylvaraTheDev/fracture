{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home-manager.users.elyria =
    { pkgs, ... }:
    {
      programs.emacs = {
        enable = true;
        package = pkgs.emacs-gtk;
        extraPackages = epkgs: [ epkgs.vterm ];
      };
    };
}
