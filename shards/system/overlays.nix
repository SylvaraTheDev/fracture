{
  inputs,
  ...
}:

{
  nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned

    # Deckmaster patch: Adds text overlay support for Stream Deck buttons
    # This patch introduces two new ButtonWidget configuration options:
    #   - overlay (bool): Renders text on top of the icon instead of beside it
    #   - labelTop (bool): Positions the label at the top of the button (default: bottom)
    # These options enable more flexible button layouts, particularly useful for
    # buttons that need both an icon and descriptive text without shrinking the icon.
    (final: prev: {
      infuse = (import inputs.infuse { inherit (prev) lib; }).v1;
      deckmaster = final.infuse.infuse prev.deckmaster {
        __output.patches.__append = [ ../../patches/deckmaster-overlay-text.patch ];
      };
    })
  ];
}
