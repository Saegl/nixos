{pkgs, ...}: {
  home.packages = with pkgs; [
    river # Tile WM
    xdg-desktop-portal-wlr # Screen sharing? and maybe something else
    wbg # Wallpaper
    fnott # Notifications
    libnotify # Test notifications
    cliphist # fuzzel clipboard
  ];

  home.file.".config/river/init".source = ./init;

  # Unbloated login manager
  programs.fish.interactiveShellInit = ''
    if status is-login; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
        exec river
    end
  '';
}
