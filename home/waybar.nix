{pkgs, ...}: {
  home.packages = with pkgs; [
    alsa-utils # For sound buttons
    brightnessctl # For brightness buttons
  ];
  programs.waybar.enable = true;
  home.file.".config/waybar/config.jsonc".source = ../dotfiles/waybar/config.jsonc;
  home.file.".config/waybar/style.css".source = ../dotfiles/waybar/style.css;
  home.file.".config/waybar/style_minimal.css".source = ../dotfiles/waybar/style_minimal.css;
}
