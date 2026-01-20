{ config, pkgs, ... }:

{
  security.sudo.enable = false;
  security.polkit.enable = true;

  # Add run0 alias if needed, or rely on systemd-run
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "sudo" ''
      exec run0 "$@"
    '')
  ];
}
