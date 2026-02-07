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
    programs = {
      fastfetch.enable = true;
      btop.enable = true;
      eza.enable = true;
      bat.enable = true;
      fzf.enable = true;
      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };
      ripgrep.enable = true;
    };
    xdg.configFile."fastfetch/images".source = ../../dotfiles/fastfetch/images;

    home.persistence."/persist".directories = [
      ".local/share/zoxide"
    ];
  };

  environment.systemPackages = with pkgs; [
    fastfetch
  ];
}
