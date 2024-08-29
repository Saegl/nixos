{pkgs, ...}: {
  imports = [
    ./dev.nix
    ./river/river.nix
    ./kitty/kitty.nix
    ./starship/starship.nix
    ./xdg.nix
    ./fuzzel/fuzzel.nix
    ./waybar/waybar.nix
    ./gtk.nix
    ./fish.nix
    ./apps.nix
  ];
  home.username = "saegl";
  home.homeDirectory = "/home/saegl";
  home.stateVersion = "23.11";
}
