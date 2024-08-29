{pkgs, ...}: {
  home.packages = with pkgs; [
    hugo # static site generator for blog
    pandoc # documents converter
    texlive.combined.scheme-small # pandoc to pdf
    newsboat # RSS reader
    # System
    btop
    dust # rust alt to "du"
    lm_sensors # type "sensors" to see cpu, gpu temps
    dconf2nix # Import gnome settings to nix
    ffmpeg
    # gaming
    bottles
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
        wineWowPackages.waylandFull
      ];
    })
    antimicrox
    sc-controller
    # Deprecated: try semeru-jre-bin-8
    # adoptopenjdk-jre-openj9-bin-8 # for minecraft launcher
    mangohud
    # Graphics
    krita
    aseprite
    gimp
    pastel # colors in cli
    loupe # gnome image viewer
    # Chess
    cutechess
    stockfish
    # Regular programs
    firefox
    qutebrowser
    protonvpn-gui
    spotify
    syncthing
    bitwarden
    telegram-desktop
    appimage-run
    qbittorrent
    discord
    anki
    thunderbird
    baobab # gnome disk usage
    wineWowPackages.stable
    vlc
    obs-studio
    # lmstudio
  ];

  programs.zathura.enable = true;
}
