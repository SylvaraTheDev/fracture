{ config, ... }:

{
  home-manager.users.${config.fracture.user.login} = _: {
    programs.ghostty.enable = true;
  };
}
