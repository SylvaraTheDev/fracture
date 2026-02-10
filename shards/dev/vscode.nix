{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.vscode = {
      enable = true;
      profiles.default.extensions =
        with pkgs.vscode-extensions;
        [
          bbenoist.nix
          brettm12345.nixfmt-vscode
          mkhl.direnv
          ms-azuretools.vscode-docker
          ms-kubernetes-tools.vscode-kubernetes-tools
          elixir-lsp.vscode-elixir-ls
          golang.go
          dart-code.dart-code
          nefrob.vscode-just-syntax
          haskell.haskell
          ms-python.python
          ms-toolsai.jupyter
          ms-vscode.cpptools
          esbenp.prettier-vscode
          redhat.vscode-yaml
          pkief.material-icon-theme
        ]
        ++ [
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
            mktplcRef = {
              name = "nix-embedded-languages";
              publisher = "coopermaruyama";
              version = "0.0.2";
            };
            vsix = pkgs.fetchurl {
              url = "https://open-vsx.org/api/coopermaruyama/nix-embedded-languages/0.0.2/file/coopermaruyama.nix-embedded-languages-0.0.2.vsix";
              sha256 = "07xpphwzyc1z32d8gfar2pxzcvdbzq3rf3ibwmzqd28xgkc4imi7";
              name = "coopermaruyama-nix-embedded-languages.zip";
            };
          })
        ];
      profiles.default.userSettings = {
        "editor.fontFamily" = "Fira Code Nerd Font, 'Fira Code', monospace";
        "editor.fontLigatures" = true;
        "window.dialogStyle" = "custom";
        "git.confirmSync" = false;
        "git.enableSmartCommit" = true;
        "explorer.confirmDelete" = false;
        "chat.mcp.gallery.enabled" = true;
        "workbench.iconTheme" = "material-icon-theme";
      };
    };

    home.persistence."/persist".directories = [
      ".config/Code"
    ];
  };
}
