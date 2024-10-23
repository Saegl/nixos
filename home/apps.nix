{pkgs, ...}: {
  home.packages = with pkgs; [
    hugo # static site generator for blog
    pandoc # documents converter
    texlive.combined.scheme-small # pandoc to pdf
    newsboat # RSS reader
    typioca # touch typing
    # System
    btop
    dust # rust alt to "du"
    lm_sensors # type "sensors" to see cpu, gpu temps
    dconf2nix # Import gnome settings to nix
    ffmpeg
    graphviz
    ripdrag # drag and drop from terminal
    exiftool
    ouch # archives
    # gaming
    bottles
    wineWowPackages.stable
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
        wineWowPackages.waylandFull
      ];
    })
    antimicrox
    sc-controller
    semeru-jre-bin-8 # for minecraft launcher
    mangohud
    # Graphics
    # krita
    # aseprite
    gimp
    pastel # colors in cli
    loupe # gnome image viewer
    # Chess
    cutechess
    stockfish
    # Media
    vlc
    mpv
    yt-dlp
    spotify
    quodlibet
    # Regular programs
    firefox
    qutebrowser
    protonvpn-gui
    syncthing
    bitwarden
    telegram-desktop
    appimage-run
    qbittorrent
    discord
    anki
    thunderbird
    baobab # gnome disk usage
    # obs-studio
    # lmstudio
  ];

  programs.zathura.enable = true;
}
