{
  pkgs,
  ...
}:

{
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/persist/etc/sops/age/keys.txt";
  };

  environment.systemPackages = with pkgs; [
    sops
    age
  ];

  environment.persistence."/persist".files = [
    "/etc/sops/age/keys.txt"
  ];
}
