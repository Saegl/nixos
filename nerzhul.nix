{pkgs, ...}: {
  user.shell = "${pkgs.fish}/bin/fish";
  environment.packages = with pkgs; [
    which
    neovim
    neofetch
    git
    python312
    openssh
    unison
    unixtools.ifconfig
    fish
    starship
  ];
  system.stateVersion = "24.05";
}
