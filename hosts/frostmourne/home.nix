{...}: {
  imports = [
    ./../../home/homebundle.nix
  ];
  home.username = "saegl";
  home.homeDirectory = "/home/saegl";
  home.stateVersion = "23.11";

  fuzzel.enable = true;
  kitty.enable = false;
  foot.enable = true;
  python.enable = true;
}
