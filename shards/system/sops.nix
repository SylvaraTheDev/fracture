{
  pkgs,
  ...
}:

{
  # Sops-nix configuration for secrets management
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/etc/sops/age/keys.txt";
  };

  environment.systemPackages = with pkgs; [
    sops
    age
  ];
}
