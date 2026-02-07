{
  config,
  inputs,
  ...
}:

{
  home-manager.users.${config.fracture.user.login} =
    { ... }:
    {
      imports = [ inputs.zen-browser.homeModules.twilight ];
      programs.zen-browser.enable = true;
      programs.chromium.enable = true;
    };
}
