{pkgs, ...}: {
  home.packages = with pkgs; [
    river # Tile WM
    xdg-desktop-portal-wlr # Screen sharing? and maybe something else
    waybar # statusbar
    wbg # Wallpaper
    fuzzel # App launcher
    bemoji # emoji for fuzzel
    fnott # Notifications
    libnotify # Test notifications
    cliphist # fuzzel clipboard
    swayimg # Image viewer
  ];

  # Unbloated login manager
  programs.fish.interactiveShellInit = ''
    if status is-login; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
        exec river
    end
  '';
}
