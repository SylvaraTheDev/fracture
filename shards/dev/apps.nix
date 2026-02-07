{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.systemPackages = with pkgs; [
    zed-editor
    adoptopenjdk-icedtea-web
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      # Languages
      zig
      elixir
      erlang
      flutter

      # Nix tools
      nil
      nixd
      nixdoc
      nh
      nix-output-monitor
      deadnix
      statix
      alejandra
      nix-tree

      # Build tools
      just
      gnumake
      pre-commit
      devenv

      # Package managers
      uv
      pnpm

      # Git extras
      git-credential-manager
      onefetch
      gource
    ];
  };
}
