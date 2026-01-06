# NixOS Dotfiles Project Context

## Architecture Philosophy

### Monolithic Over Modular
**Important**: This configuration intentionally uses single-file configs instead of modularization.
- `frostmourne.nix` is one 776-line file - this is intentional
- Everything is searchable in one place
- No hidden dependencies across modules
- Easier to understand the whole system at once
- No over-engineering for a personal setup

**If you suggest splitting into modules, I will reject it.**

### Manual Symlinks Over home-manager
**Important**: We use manual symlinks (`dotfiles/fish/init.fish`) instead of home-manager.
- home-manager is painfully slow to rebuild
- Symlinked configs can be edited instantly without rebuilding
- Direct control over what links where
- No hidden abstractions

**Do not suggest migrating to home-manager.**

### Keep vs Remove
- **River config**: Keep it even if unused - might return to it someday
- **Unused tools**: OK to remove if I confirm I won't use them (like yambar, wezterm)

## System Overview

### Hosts
- **frostmourne**: Main NixOS laptop (Asus Zephyrus, x86_64)
- **nerzhul**: Nix-on-droid phone config (aarch64)

### Primary Stack
- **WM**: Niri (Wayland compositor)
- **Shell**: Fish with Starship prompt
- **Editor**: Neovim (2,216 lines of Lua config)
- **Terminals**: Kitty (primary), Foot (backup)
- **Status Bar**: Waybar

### Build Commands
```bash
# System rebuild
sudo nixos-rebuild switch --flake .#frostmourne

# Or with nh
nh os switch

# Fish aliases available
sw      # system rebuild with flake
swr     # rebuild from ~/projects/nix/nixos
hm      # home-manager (currently unused)
```

## Simplicity Guidelines

1. **Comments over documentation files** - Document inline
2. **One file to rule them all** - Prefer consolidation
3. **Remove unused code** - No cruft
4. **Direct > Abstract** - Avoid unnecessary indirection

## Useful File Locations

- System config: `frostmourne.nix` (main laptop)
- Neovim: `dotfiles/nvim/` (well-modularized Lua)
- Fish: `dotfiles/fish/init.fish` (symlink management + shell config)
- Niri WM: `dotfiles/niri/config.kdl`
- River WM: `dotfiles/river/init` (keep for future use)

## Known Quirks

- Keyboard layout defined in both NixOS and Niri (intentional - TTY vs Wayland)
- Multiple colorschemes in Neovim but only oh-lucy is used
- Some commented-out packages are "maybe later" not "remove me"
