{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prismlauncher
  ];

  home-manager.users.${config.fracture.user.login} = _: {
    home.persistence."/persist".directories = [
      ".local/share/PrismLauncher"
    ];
  };
}
