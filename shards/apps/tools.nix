{
  pkgs,
  ...
}:

{
  home-manager.users.elyria =
    _:

    {
      programs.fastfetch.enable = true;
      xdg.configFile."fastfetch/images".source = ../../dotfiles/fastfetch/images;
      programs.btop.enable = true;
      programs.eza.enable = true;
      programs.bat.enable = true;
      programs.fzf.enable = true;
      programs.zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };
      programs.ripgrep.enable = true;
    };

  environment.systemPackages = with pkgs; [
    fastfetch
  ];
}
