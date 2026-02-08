{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kubernetes
    kubernetes-helm
    freelens-bin
  ];
}
