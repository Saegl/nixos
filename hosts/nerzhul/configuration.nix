{pkgs, ...}: {
  user.shell = "${pkgs.fish}/bin/fish";
  environment.packages = with pkgs; [
    neovim
    neofetch
    git
    python312
  ];
  system.stateVersion = "24.05";
  home-manager = {
    useGlobalPkgs = true;

    config = {
      config,
      lib,
      pkgs,
      ...
    }: {
      home.stateVersion = "24.05";
      programs.fish.enable = true;
    };
  };
}
