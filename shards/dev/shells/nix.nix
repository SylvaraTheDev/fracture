{
  pkgs,
  __isDevShell ? false,
  ...
}:
if __isDevShell then
  {
    packages = with pkgs; [
      prek
      nil
      nixd
      gitleaks
      just
    ];

    enterShell = ''
      if [ -d .git ]; then
        prek install --install-hooks 2>/dev/null || true
      fi
    '';
  }
else
  { }
