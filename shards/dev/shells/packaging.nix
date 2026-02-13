{
  pkgs,
  __isDevShell ? false,
  ...
}:
if __isDevShell then
  {
    packages = with pkgs; [
      nix-init
      nurl
    ];
    enterShell = ''
      echo "Nix packaging shell (nix-init + nurl)"
      nix-init --version
    '';
  }
else
  { }
