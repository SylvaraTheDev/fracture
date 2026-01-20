{ config, pkgs, ... }:

{
  security.sudo.enable = false;
  security.polkit.enable = true;
  security.run0.enableSudoAlias = true;
}
