{
  config,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  sops = {
    defaultSopsFormat = "yaml";
    age.keyFile = "/persist/etc/sops/age/keys.txt";

    secrets.github-token = {
      sopsFile = config.fracture.secretsDir + "/api/keys.yaml";
      key = "api/github-token";
      mode = "0400";
      owner = "root";
      group = "root";
    };

    secrets.github-ssh-key = {
      sopsFile = config.fracture.secretsDir + "/ssh/keys.yaml";
      key = "ssh/github-ssh-key";
      owner = login;
      group = "users";
      path = "/home/${login}/.ssh/id_ed25519_github";
    };

    templates."nix-access-tokens" = {
      content = ''
        access-tokens = github.com=${config.sops.placeholder.github-token}
      '';
      mode = "0400";
      owner = "root";
      group = "root";
    };
  };

  nix.extraOptions = ''
    !include ${config.sops.templates."nix-access-tokens".path}
  '';

  environment.systemPackages = with pkgs; [
    sops
    age
  ];

  environment.persistence."/persist".files = [
    "/etc/sops/age/keys.txt"
  ];
}
