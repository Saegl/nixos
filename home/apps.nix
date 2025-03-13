{pkgs, ...}: {
  home.packages = with pkgs; [
    ############### System
    appimage-run # run appimage executables
    # baobab # gnome disk usage
    foot # foot fetish stuff (wayland native terminal emulator)

    ############### CLI tools
    dust # rust alt to "du"
    ripdrag # drag and drop from terminal
    calc # calculator
    unzip # unzip .zip files
    ouch # unzip various archives
    sqlite # Single file SQL database
    tmux # Many terminals in one terminal
    tlrc # "man" but shorter, fork of "tldr"
    file # get file info
    typioca # touch typing, when typeracer.com is down
    exiftool # metadata of file, more for images
    ripgrep # "grep" but faster
    jq # JSON for terminal nerds
    fd # "find" but faster
    fzf # fuzzy finder
    # gh # github cli
    tree # print file tree
    tre-command # like "tree" but "tre"
    binsider # elf analyzer
    newsboat # RSS reader

    ############### Monitoring tools
    btop # General purpose
    iotop # monitor disk usage
    nvtopPackages.nvidia # GPU
    batmon # Battery
    lm_sensors # type "sensors" to see cpu, gpu temps

    ############### Regular programs
    unison # fily sync
    # syncthing # file sync
    bitwarden # leak passwords
    telegram-desktop # send messages to pavel durov
    qbittorrent # best torrenting program
    discord # modern forums
    # anki # memorization helper
    # thunderbird # emails, just use browser
    graphviz # Graphs visualization

    ############### Graphics
    # krita # Pro Painter
    # aseprite # 2d artist (buy license!)
    # gimp # photoshop but worse, use photopea.com
    pastel # colors in cli
    loupe # gnome image viewer

    ############### Media
    vlc # video player
    mpv # video player but cooler
    ffmpeg # Media tools in terminal
    yt-dlp # youtube pirate
    spotify # Music subscription
    quodlibet # minimalistic GUI audio player in python
    # obs-studio # Streamer tools
    # lmms # App for music composing, free fl studio

    ############### Browsing
    firefox # web browser
    # qutebrowser # vim web browser
    # protonvpn-gui # vpn
    openvpn # open vpn
    ungoogled-chromium # for emergency
    # google-chrome # for higher emergency

    ############### Gaming
    # bottles # wine GUI
    wineWowPackages.stable # not emulator
    vulkan-tools
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
        wineWowPackages.waylandFull
      ];
    })
    # antimicrox # controller configuration
    # sc-controller # controller configuration
    # semeru-jre-bin-8 # for minecraft launcher
    mangohud # FPS counter

    ############### Chess
    cutechess # GUI for UCI chess engines
    stockfish # best chess engine
    en-croissant # electron GUI

    ############### Text
    # zed-editor # Rust GUI text editor (merge of VSC*DE and VIM)
    # neovide # smooth GUI for neovim
    hugo # static site generator for blog
    # pandoc # documents converter
    # texlive.combined.scheme-small # pandoc to pdf

    ############### LLM
    # lmstudio # advanced GUI

    ############### WEB tools
    caddy # nginx but simpler
    httpie # curl in python
    nmap # hecker stuff
    rustscan # as nmap

    ############### DEV
    just # "make" but not for c/c++
    tokei # count lines of code
    bat # "cat" but colorful

    ############### Lua tools
    # lua # smol pl
    # love # loved game engine

    ############### Rust tools
    rustup # rust setup.exe

    ############### Lean tools
    # elan # rustup for math

    ############### Nix tools
    nixd # Nix LSP
    alejandra # Nix formatter

    ############### C/C++/asm tools
    gnumake # build tools
    cmake # build tools but harder
    clang-tools # clangd lsp
    gcc # compilers
    gdb # debugger
    nasm # x86 asm compiler
    valgrind # memory profiler
    protobuf # binary serialization

    ############### Android
    # android-studio # android studio
    # flutter # cross platform UI

    ############### Window manager
    # river # Tile WM
    xdg-desktop-portal-wlr # Screen sharing? and maybe something else
    # wbg # wayland wallpaper
    swaybg # wayland wallpaper
    fnott # Notifications
    libnotify # Test notifications
    lswt # list wayland toplevel (get window names)
    wayland-utils # show supported protocols
    grim # make screenshot
    slurp # choose region
    # grim -g $(slurp -d)
    # wl-kbptr # vim F in window
    xwayland-satellite # xwayland on app level
    fuzzel # app launcher + fuzzy finder
    bemoji # emoji
    cliphist # clipboard
    # yambar # waybar but simpler
  ];

  home.sessionPath = [
    "/home/saegl/.cargo/bin"
  ];

  # Source code version control
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Saegl";
    userEmail = "saegl@protonmail.com";
    includes = [
      {
        contents = {
          init.defaultBranch = "main";
        };
      }
    ];
  };

  # shell prompt
  programs.starship = {
    enable = true;
  };

  # Vim-like book reader
  programs.zathura.enable = true;
}
