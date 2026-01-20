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
      programs.waybar.enable = true;
    };
}
