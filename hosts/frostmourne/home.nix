{...}: {
  imports = [
    ./../../home/xdg.nix
    ./../../home/gtk.nix
    ./../../home/fish.nix
    ./../../home/apps.nix
    ./../../home/dotfiles.nix
  ];
  home.username = "saegl";
  home.homeDirectory = "/home/saegl";
  home.stateVersion = "23.11";
}
