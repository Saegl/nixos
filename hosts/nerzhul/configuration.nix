{pkgs, ...}: {
  environment.packages = with pkgs; [
    neovim
    neofetch
    git
    python312
  ];
  system.stateVersion = "24.05";
}
