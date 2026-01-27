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
      programs.fastfetch.enable = true;
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
