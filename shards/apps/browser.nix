{
  inputs,
  ...
}:

{
  home-manager.users.elyria =
    { ... }:
    {
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser.enable = true;
      programs.chromium.enable = true;
    };
}
