{
  fracture = {
    hostname = "fracture";
    stateVersion = "25.11";

    user = {
      login = "elyria";
      name = "Elyria";
      email = "wing@elyria.dev";
      groups = [
        "networkmanager"
        "wheel"
        "video"
        "input"
        "podman"
        "kvm"
      ];
    };

    timezone = "Australia/Brisbane";
    locale = "en_AU.UTF-8";
    gpu = "nvidia";

    vm = {
      enable = true;
      waylandDisplay = "wayland-1";
    };
  };
}
