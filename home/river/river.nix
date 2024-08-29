{pkgs, ...}: {
  home.packages = with pkgs; [
    river # Tile WM
    xdg-desktop-portal-wlr # Screen sharing? and maybe something else
    waybar # statusbar
    wbg # Wallpaper
    fnott # Notifications
    libnotify # Test notifications
    cliphist # fuzzel clipboard
    swayimg # Image viewer
    alsa-utils # For sound buttons
    brightnessctl # For brightness buttons
  ];

  home.file.".config/river/init".source = ./init;

  # Unbloated login manager
  programs.fish.interactiveShellInit = ''
    if status is-login; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
        exec river
    end
  '';
}
