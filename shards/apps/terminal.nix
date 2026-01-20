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
      programs.ghostty.enable = true;
      programs.alacritty.enable = true;
    };
}
