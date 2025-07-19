# My NixOS config
## Installation (works only on Asus Zephyrus m16 GU603HE)

1. clone this repo into projects dir
2. replace /etc/nixos/ with symbolic link to this repo
3. `sudo nixos-rebuild switch`

## Installation (As terminal app on phone)

1. Install F-Droid (https://f-droid.org/)
2. Install Nix-on-droid in F-Droid
3. Give permissions (Including `Files` from phone settings, this will give
   access to `/mnt/sdcard` later)
4. In Nix-on-droid `Do you want to set it up with flakes`> no (not for the
   initial installation, step 7 adds flakes support)
5. Add git `nix-shell -p git`
6. Clone repo `git clone https://github.com/Saegl/nixos.git` in home folder
7. Update system `nix-on-droid switch --flake ~/nixos/#nerzhul`
8. Symlink `config.fish` with `ln -s ~/nixos/dotfiles/fish/nerzhul.fish ~/.config/fish/config.fish`
8. Done

There is also `ssh` support
1. Generate keys with `ssh-keygen`
2. Add laptop keys to `.ssh/authorized_keys`
3. Start ssh server `sshserver` (alias)

