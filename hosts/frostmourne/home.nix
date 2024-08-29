{...}: {
  imports = [
    ./../../home/homebundle.nix
  ];
  home.username = "saegl";
  home.homeDirectory = "/home/saegl";
  home.stateVersion = "23.11";
}
