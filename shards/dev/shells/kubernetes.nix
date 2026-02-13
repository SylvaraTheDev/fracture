{ pkgs }:
{
  packages = with pkgs; [
    kubectl
    talosctl
    omnictl
    helm
  ];
  enterShell = ''
    echo "Kubernetes development shell"
    kubectl version --client --short 2>/dev/null || echo "kubectl ready"
  '';
}
