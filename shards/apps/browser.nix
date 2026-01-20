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
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser.enable = true;
      programs.firefox.enable = true;
    };
}
