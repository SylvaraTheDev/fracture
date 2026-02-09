_:

{
  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd"
      ];
      files = [
        "/etc/machine-id"
      ];
    };

    "/persist-projects" = {
      hideMounts = true;
      directories = [ ];
    };

    "/persist-games" = {
      hideMounts = true;
      directories = [ ];
    };
  };
}
