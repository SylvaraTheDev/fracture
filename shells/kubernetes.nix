{ mkDevShell, pkgs, ... }:
mkDevShell {
  packages = [
    pkgs.kubectl
    pkgs.talosctl
    pkgs.omnictl
    pkgs.helm
  ];
  enterShell = ''
    echo "Kubernetes development shell"
    kubectl version --client --short 2>/dev/null || echo "kubectl ready"
  '';
}
