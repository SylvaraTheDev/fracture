# Dotfiles Sync Plan: Forge → Fracture

## Context

Fracture (`/home/aeon/git/sylvara/fracture`) is a NixOS config being ported from Forge (`~/.config/nix`).
The `shards/desktop/dotfiles.nix` module is DONE - it wires `dotfiles/` into home-manager.
What remains is syncing the actual dotfile contents from Forge to Fracture.

## Status of dotfiles.nix

COMPLETE at `shards/desktop/dotfiles.nix`. It maps:
- `dotfiles/mako` → `~/.config/mako`
- `dotfiles/niri` → `~/.config/niri`
- `dotfiles/nushell` → `~/.config/nushell`
- `dotfiles/fastfetch/images` → `~/.config/fastfetch/images`
- `dotfiles/quickshell` → `~/.config/quickshell`
- `dotfiles/emacs` → `~/.emacs.d`
- `dotfiles/deckmaster` → `~/.config/deckmaster`
- `dotfiles/zed` → `~/.config/zed`
- Cursor: Bibata-Modern-Ice, size 24
- Dark mode via dconf

## Files Missing from Fracture dotfiles/

These exist in Forge (`~/.config/nix/dotfiles/`) but NOT in Fracture (`fracture/dotfiles/`):

### Must copy from Forge:
1. `emacs/init.el` - Emacs init config
2. `emacs/modules/keybindings.el` - Emacs keybindings
3. `quickshell/shell.qml` - Quickshell QML config
4. `quickshell/logic/build.nix` - Quickshell build
5. `quickshell/logic/justfile` - Quickshell build commands
6. `quickshell/logic/metrics.cpp` - Quickshell C++ metrics
7. `nushell/functions/zoxide.nu` - Missing zoxide integration
8. `deckmaster/assets/mic_off.png` - Missing button images
9. `deckmaster/assets/mic_on.png`
10. `deckmaster/assets/music.png`
11. `deckmaster/assets/next.png`
12. `deckmaster/assets/prev.png`

### Intentionally excluded (user confirmed):
- `gemini/` - gemini-cli removed
- `sillytavern/` - not porting
- `waybar/` - purged, using Noctalia instead

## Commands to sync missing files:

```bash
# Emacs config
mkdir -p dotfiles/emacs/modules
cp ~/.config/nix/dotfiles/emacs/init.el dotfiles/emacs/init.el
cp ~/.config/nix/dotfiles/emacs/modules/keybindings.el dotfiles/emacs/modules/keybindings.el

# Quickshell
mkdir -p dotfiles/quickshell/logic
cp ~/.config/nix/dotfiles/quickshell/shell.qml dotfiles/quickshell/shell.qml
cp ~/.config/nix/dotfiles/quickshell/logic/build.nix dotfiles/quickshell/logic/build.nix
cp ~/.config/nix/dotfiles/quickshell/logic/justfile dotfiles/quickshell/logic/justfile
cp ~/.config/nix/dotfiles/quickshell/logic/metrics.cpp dotfiles/quickshell/logic/metrics.cpp

# Nushell missing function
cp ~/.config/nix/dotfiles/nushell/functions/zoxide.nu dotfiles/nushell/functions/zoxide.nu

# Deckmaster missing assets
cp ~/.config/nix/dotfiles/deckmaster/assets/mic_off.png dotfiles/deckmaster/assets/mic_off.png
cp ~/.config/nix/dotfiles/deckmaster/assets/mic_on.png dotfiles/deckmaster/assets/mic_on.png
cp ~/.config/nix/dotfiles/deckmaster/assets/music.png dotfiles/deckmaster/assets/music.png
cp ~/.config/nix/dotfiles/deckmaster/assets/next.png dotfiles/deckmaster/assets/next.png
cp ~/.config/nix/dotfiles/deckmaster/assets/prev.png dotfiles/deckmaster/assets/prev.png
```

## After syncing, also compare file CONTENTS for drift:

The following directories exist in BOTH configs but may have diverged:
- `niri/config.kdl` - window manager config (likely different monitor setup)
- `nushell/config.nu` - shell config
- `nushell/functions/aliases.nu` and `nushell/functions/nix.nu`
- `mako/config` - notification styling
- `deckmaster/main.deck` - stream deck layout
- `fastfetch/images/` - logo images
- `zed/settings.json` - editor config

Run: `diff -rq ~/.config/nix/dotfiles/ dotfiles/` to find content differences.
Decide per-file whether Forge or Fracture version is canonical.

## Other modules completed this session:

- `shards/system/ld.nix` - already existed
- `shards/dev/emacs.nix` - DONE (emacs-pgtk + packages)
- `shards/dev/kubernetes.nix` - DONE (kubectl, helm, freelens)
- `shards/desktop/dotfiles.nix` - DONE (home.file mappings + cursor + dark mode)

## Remaining deployment blockers:

1. Disk IDs in host.nix (installer handles this)
2. `secrets/auth/users.yaml` - needs real password hash
3. `secrets/ssh/config.yaml` - needs SSH config
4. SSH hardening (gate PermitRootLogin behind vm.enable) - user deferred
5. Commit all changes
