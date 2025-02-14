{pkgs, ...}: {
  home.packages = with pkgs; [
    river # Tile WM
    xdg-desktop-portal-wlr # Screen sharing? and maybe something else
    # wbg # Wallpaper
    swaybg
    fnott # Notifications
    libnotify # Test notifications
    lswt # list wayland toplevel (get window names)
    wayland-utils # show supported protocols
    grim # make screenshot
    slurp # choose region
    # grim -g $(slurp -d)
    wl-kbptr
    xwayland-satellite
  ];

  home.file.".config/river/init".source = ./init;

  # Unbloated login manager
  programs.fish.interactiveShellInit = ''
    if status is-login; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
        niri-session
    end
  '';
}
