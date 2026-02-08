{
  config,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      (if config.fracture.gpu == "nvidia" then zenith-nvidia else zenith)
      chafa
      fd
      ncdu
    ];

    programs = {
      bat.enable = true;
      btop.enable = true;
      eza.enable = true;
      fzf.enable = true;
      ripgrep.enable = true;
    };
  };
}
