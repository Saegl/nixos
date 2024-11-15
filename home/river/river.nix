{pkgs, ...}: {
  home.packages = with pkgs; [
    river # Tile WM
    xdg-desktop-portal-wlr # Screen sharing? and maybe something else
    wbg # Wallpaper
    fnott # Notifications
    libnotify # Test notifications
    lswt # list wayland toplevel (get window names)
    wayland-utils # show supported protocols
    grim # make screenshot
    slurp # choose region
    # grim -g $(slurp -d)
    wl-kbptr
  ];

  home.file.".config/river/init".source = ./init;
  home.file.".config/river/project_starter.py".source = ./project_starter.py;

  # Unbloated login manager
  programs.fish.interactiveShellInit = ''
    if status is-login; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
        exec river
    end
  '';
}
