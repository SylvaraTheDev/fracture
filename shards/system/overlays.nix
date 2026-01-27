{
  config,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
    (final: prev: {
      infuse = (import inputs.infuse { inherit (prev) lib; }).v1;
      deckmaster = final.infuse.infuse prev.deckmaster {
        __output.patches.__append = [ ./patches/deckmaster-overlay-text.patch ];
      };
    })
  ];
}
