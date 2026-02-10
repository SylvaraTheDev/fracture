_:

{
  security = {
    sudo = {
      enable = true;
      extraConfig = "Defaults lecture=never";
    };
    polkit.enable = true;
  };
}
