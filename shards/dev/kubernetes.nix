{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.systemPackages = with pkgs; [
    kubernetes
    kubernetes-helm
    freelens-bin
  ];

  home-manager.users.${login} = _: {
    home.persistence."/persist".directories = [
      ".kube"
      ".config/helm"
    ];
  };
}
