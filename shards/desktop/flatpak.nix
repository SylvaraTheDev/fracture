_:

{
  # Ensure flatpak service starts after impermanence bind-mounts /var/lib/flatpak,
  # otherwise it writes ~1.6GB to the tmpfs root before the mount covers it.
  systemd.services.flatpak-managed-install = {
    after = [ "var-lib-flatpak.mount" ];
    requires = [ "var-lib-flatpak.mount" ];
  };

  services.flatpak = {
    enable = true;
    packages = [
      "com.adamcake.Bolt"
      "com.github.tchx84.Flatseal"
    ];
    overrides = {
      "com.adamcake.Bolt" = {
        Environment = {
          MESA_LOADER_DRIVER_OVERRIDE = "zink";
          GALLIUM_DRIVER = "zink";
          __GLX_VENDOR_LIBRARY_NAME = "mesa";
          LIBVA_DRIVER_NAME = "mesa";
        };
      };
      "dev.dergs.Tonearm" = {
        "Session Bus Policy" = {
          "org.freedesktop.secrets" = "talk";
        };
      };
    };
  };

  environment.persistence."/persist".directories = [
    "/var/lib/flatpak"
  ];
}
