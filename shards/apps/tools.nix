{
  pkgs,
  ...
}:

{
  home-manager.users.elyria = _: {
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
  };

  environment.systemPackages = with pkgs; [
    fastfetch
  ];
}
