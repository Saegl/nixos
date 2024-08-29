{pkgs, ...}: {
  home.packages = with pkgs; [
    alsa-utils # For sound buttons
    brightnessctl # For brightness buttons
  ];
  programs.waybar.enable = true;
  home.file.".config/waybar/config.jsonc".source = ./config.jsonc;
  home.file.".config/waybar/style.css".source = ./style.css;
}
