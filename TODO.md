# Fracture TODO

Dendritic NixOS system configuration for the `fracture` VM.

## Completed

- [x] Core flake structure with `flake-parts`
- [x] Modular `shards/` architecture with auto-import via `findModules`
- [x] User `elyria` with Nushell, run0 (sudo replacement)
- [x] Niri window manager + Noctalia shell bar
- [x] Dotfiles infrastructure (mako, fastfetch, deckmaster, niri, nushell, zed)
- [x] System essentials (drivers, kernel, SSH, security, optimization)
- [x] Gaming setup (Steam, Gamemode)
- [x] VM verified and booting correctly
- [x] DevEnv shells (elixir, go, dart, python, kubernetes)
- [x] Nushell `dev` command for entering devshells

## In Progress

(none)

## Future Ideas

- [ ] Add more keybindings to Niri config
- [ ] Expand Noctalia widgets configuration
- [ ] Add Deckmaster systemd service (ref: previous work in `flights` module)
- [ ] Vicinae integration (currently imported but minimal config)
- [ ] Package `expert` LSP for Elixir
- [ ] Additional user profiles
