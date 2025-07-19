{
  inputs,
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.asus-zephyrus-gu603h
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  ### drivers
  boot.binfmt.emulatedSystems = ["aarch64-linux"]; # Cross compile for arm
  # Very experimental
  # hardware.nvidia.powerManagement.enable = true;
  # hardware.nvidia.powerManagement.finegrained = true;
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;
  services.devmon.enable = true; # automount usb to /run/media/saegl/<name>/
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.tlp.settings = {
    # Aggressive power saving settings
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    SCHED_POWERSAVE_ON_BAT = 1;
    WIFI_PWR_ON_BAT = "on";
    PCIE_ASPM_ON_BAT = "powersupersave";
    RUNTIME_PM_ON_BAT = "auto";
    SOUND_POWER_SAVE_ON_BAT = 1;
    SOUND_POWER_SAVE_CONTROLLER = "Y";
  };
  services.auto-cpufreq.enable = false;
  time.timeZone = "Asia/Ashgabat"; # Return to "Asia/Almaty" when updated from +6 to +5
  i18n.defaultLocale = "en_US.UTF-8";
  hardware.graphics.enable32Bit = true;
  services.libinput.enable = true;
  services.libinput.touchpad.naturalScrolling = true;

  ### ssh
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.AllowUsers = ["*@192.168.*.*"];
  };
  users.users.saegl.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEOd0Z22qitTvXUwAVMAi5EyqV6b69flhLL28Cde2VpV nix-on-droid"
  ];

  programs.adb.enable = true;
  programs.java.enable = true;
  programs.ghidra = {
    enable = true;
    gdb = true;
    package = pkgs.ghidra.withExtensions (exts:
      with exts; [
        gnudisassembler
      ]);
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  programs.git = {
    # Source code version control
    enable = true;
    lfs.enable = true;
  };
  programs.fish = {
    enable = true;
    generateCompletions = true;
    vendor = {
      config.enable = true;
      functions.enable = true;
      completions.enable = true;
    };
  };
  programs.zoxide.enable = true; # Fuzzy finder between dirs with "z"
  programs.yazi.enable = true; # file manager
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  services.ollama.enable = true;
  services.asusd.enable = true;
  # programs.waybar.enable = true;
  environment.localBinInPath = true;
  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCREEN_SCALE_FACTORS = "2";
    # QT_SCALE_FACTOR = "2"; # Useful for some apps, but multiplies with QT_SCREEN_SCALE_FACTORS for some?
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    CUDNN_PATH = "${pkgs.cudaPackages.cudnn.lib}";
    OPENSSL_DIR = "${pkgs.openssl.dev}";
    OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
    OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
    FONTS = "/run/current-system/sw/share/X11/fonts";
  };
  environment.systemPackages = with pkgs; [
    ### System
    wget
    htop
    man-pages
    killall
    asusctl
    lshw
    lsof
    neofetch
    starship
    appimage-run # run appimage executables
    # baobab # gnome disk usage
    foot # foot fetish stuff (wayland native terminal emulator)
    quickemu # OS downloader
    pavucontrol # sound manager
    pciutils # lspci

    ### Nvidia stuff
    cudaPackages.cuda_cudart
    cudaPackages.cudnn
    cudaPackages.libcublas
    cudaPackages.cudatoolkit
    cudaPackages.nsight_systems

    ### CLI tools
    dust # rust alt to "du"
    ripdrag # drag and drop from terminal
    calc # calculator
    unzip # unzip .zip files
    ouch # unzip various archives
    p7zip # unzip everything
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
    tree # print file tree
    tre-command # like "tree" but "tre"
    binsider # elf analyzer
    newsboat # RSS reader

    ### Monitoring tools
    btop # General purpose
    iotop # monitor disk usage
    nethogs # monitor network usage
    nvtopPackages.nvidia # GPU
    batmon # Battery
    powertop # Battery 2
    lm_sensors # type "sensors" to see cpu, gpu temps

    ### Regular programs
    pomodoro-gtk # 25 minutes timer
    unison # fily sync
    # syncthing # file sync
    bitwarden # leak passwords
    keepassxc # offline passwords
    telegram-desktop # send messages to pavel durov
    qbittorrent # best torrenting program
    discord # modern forums
    # anki # memorization helper
    # thunderbird # emails, just use browser
    graphviz # Graphs visualization
    zathura # Vim-like book reader

    ### Graphics
    # krita # Pro Painter
    # aseprite # 2d artist (buy license!)
    # gimp # photoshop but worse, use photopea.com
    pastel # colors in cli
    loupe # gnome image viewer

    ### Media
    vlc # video player
    mpv # video player but cooler
    ffmpeg # Media tools in terminal
    opusTools # music format for the future (but not present)
    yt-dlp # youtube pirate
    youtube-music # youtube pirate 2
    spotify # Music subscription
    quodlibet # minimalistic GUI audio player in python
    # obs-studio # Streamer tools
    # lmms # App for music composing, free fl studio
    blender
    # audacity
    godot_4
    # apksigner

    ### Browsing
    firefox # web browser
    # qutebrowser # vim web browser
    # protonvpn-gui # vpn
    openvpn # open vpn
    ungoogled-chromium # for emergency
    # google-chrome # for higher emergency

    ### Gaming
    # bottles # wine GUI
    wineWowPackages.stableFull # not emulator
    vulkan-tools
    (lutris.override {
      extraLibraries = pkgs: [
        # List library dependencies here
        wineWowPackages.stableFull
        # wineWowPackages.waylandFull
      ];
    })
    # antimicrox # controller configuration
    # sc-controller # controller configuration
    # semeru-jre-bin-8 # for minecraft launcher
    mangohud # FPS counter

    ### Chess
    cutechess # GUI for UCI chess engines
    stockfish # best chess engine
    lc0 # FOSS alphazero
    en-croissant # electron GUI

    ### Text
    zed-editor # Rust GUI text editor (merge of VSC*DE and VIM)
    neovide # smooth GUI for neovim
    hugo # static site generator for blog
    # pandoc # documents converter
    # texlive.combined.scheme-small # pandoc to pdf

    ### LLM
    # lmstudio # advanced GUI
    gemini-cli # auto development

    ### WEB tools
    caddy # nginx but simpler
    httpie # curl in python
    nmap # hecker stuff
    rustscan # as nmap

    ### DEV
    gh # github cli
    just # "make" but not for c/c++
    tokei # count lines of code
    bat # "cat" but colorful

    ### Python tools
    uv # python cargo
    ruff # python linters impl in rust
    pyright # Python lsp from Microsoft
    # micromamba # smaller "conda", full OS in your venv
    # pipx # to install newer uv
    (pkgs.python312.withPackages (ps:
      with ps; [
        ipython
        pytest
        numpy
        # DAP
        debugpy
        # markdown
        grip # markdown preview
        guessit # guess media metadata
        # argostranslate # offline translate app
      ]))

    ### Lua tools
    # lua # smol pl
    # love # loved game engine

    ### Rust tools
    rustup # rust setup.exe

    ### Lean tools
    elan # rustup for math

    ### Nix tools
    nixd # Nix LSP
    alejandra # Nix formatter

    ### C/C++/asm tools
    gnumake # build tools
    cmake # build tools but harder
    clang-tools # clangd lsp
    gcc # compilers
    # clang # collision with gcc
    meson # c build system in python
    gdb # debugger
    strace # trace syscalls
    ltrace # trace libcalls
    gf # gui debugger
    nasm # x86 asm compiler
    valgrind # memory profiler
    protobuf # binary serialization
    blink # x86_64 emulator
    radare2 # reverse engineering
    iaito # gui for radare2

    ### Android
    # android-studio # android studio
    # flutter # cross platform UI

    ### Window manager
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
    alsa-utils # For sound buttons
    brightnessctl # For brightness buttons
    wl-clipboard # wayland clipboard tool
    wev # check keyboard key keycode
    waybar
    gnome-themes-extra # Adwait dark
    (pkgs.writeShellScriptBin "next_asus_profile" ./bin/next_asus_profile.sh)
    (pkgs.writeShellScriptBin "window_switch" ./bin/window_switch.sh)
    (pkgs.writeShellScriptBin "ghidra_patch" ./bin/ghidra_patch.sh)

    ### Android
    lua-language-server
    vscode-langservers-extracted # html/css/json/eslint
    ltex-ls # grammar checker (markdown, latex)
    # ruff-lsp # python linter
    marksman # markdown
  ];
  programs.niri.enable = true;
  programs.river.enable = false;
  programs.river.extraPackages = [];

  ### users
  users.users.saegl = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
    ];
    createHome = true;
  };

  ### boot
  # boot.initrd.verbose = false;
  # boot.plymouth.enable = true;
  # boot.consoleLogLevel = 0;
  # boot.kernelParams = ["quiet" "udev.log_level=0"];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    configurationLimit = 10;
    timeoutStyle = "hidden"; # hold shift to show nixos generations
    splashImage = null;
  };

  ### bluetooth
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  ### sound
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ### fonts
  # search installed fonts with
  # fc-list | grep -i <prefix>
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.iosevka-term
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
    monocraft
    fantasque-sans-mono
  ];
  # symlink fonts to /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  ### gaming
  programs.gamemode.enable = true;
  programs.gamemode.enableRenice = true;
  programs.gamescope.enable = true;
  programs.gamescope.capSysNice = true;
  programs.gamescope.args = [
    "--rt" # Real time priority
    # "--prefer-vk-device 10de:25a0" # Use the NVIDIA GeForce RTX 3050 Ti Mobile
    "-W"
    "2560"
    "-H"
    "1600"
    "-r"
    "165"
  ];
  # programs.gamescope.env = {
  #   __NV_PRIME_RENDER_OFFLOAD = "1";
  #   __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
  #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  #   __VK_LAYER_NV_optimus = "NVIDIA_only";
  # };
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.dedicatedServer.openFirewall = true;
  programs.steam.extraPackages = with pkgs; [
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXScrnSaver
    libpng
    libpulseaudio
    libvorbis
    stdenv.cc.cc.lib
    libkrb5
    keyutils
  ];

  ### networking
  networking.networkmanager.enable = true;
  networking.hostName = "frostmourne";
  networking.firewall.enable = false;

  networking.interfaces."lo".ipv4.addresses = [
    {
      address = "127.0.0.2";
      prefixLength = 32;
    }
  ];

  networking.stevenblack = {
    enable = false;
    block = ["fakenews" "gambling" "porn" "social"];
  };

  ### virt
  virtualisation.libvirtd.enable = false;
  programs.virt-manager.enable = false;

  ### x11
  services.xserver.enable = false;
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:alt_shift_toggle";

  ### xdg
  # xdg.enable = true;
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "image/svg+xml" = "org.gnome.Loupe.desktop";
    "image/png" = "org.gnome.Loupe.desktop";
    "image/jpeg" = "org.gnome.Loupe.desktop";
    "image/jpg" = "org.gnome.Loupe.desktop"; # Optional: 'jpg' is technically just a common extension for 'jpeg'
    "application/pdf" = "org.pwmt.zathura.desktop";
    "application/postscript" = "org.pwmt.zathura.desktop";
    "application/vnd.comicbook+zip" = "org.pwmt.zathura.desktop";
    "application/vnd.comicbook-rar" = "org.pwmt.zathura.desktop";
    "application/vnd.ms-xpsdocument" = "org.pwmt.zathura.desktop";
    "application/x-bzpdf" = "org.pwmt.zathura.desktop";
    "application/x-ext-djv" = "org.pwmt.zathura.desktop";
    "application/x-ext-djvu" = "org.pwmt.zathura.desktop";
    "application/x-ext-eps" = "org.pwmt.zathura.desktop";
    "application/x-ext-pdf" = "org.pwmt.zathura.desktop";
    "application/x-gzpdf" = "org.pwmt.zathura.desktop";
    "application/x-xzpdf" = "org.pwmt.zathura.desktop";
    "image/tiff" = "org.pwmt.zathura.desktop";
    "image/vnd.djvu+multipage" = "org.pwmt.zathura.desktop";
    "image/x-bzeps" = "org.pwmt.zathura.desktop";
    "image/x-eps" = "org.pwmt.zathura.desktop";
    "image/x-gzeps" = "org.pwmt.zathura.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "text/html" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
  };

  ### nix
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.settings.max-jobs = 4;
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  programs.nh = {
    enable = true;
    flake = "/home/saegl/projects/nix/nixos";
  };
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # For nixd LSP

  # NEVER CHANGE
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

  ### Things below made by `nixos-generate-config`
  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1dd7da41-6611-4227-be23-5f63d396e921";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8F98-0342";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/d33cb675-34b1-4054-a9a0-4cd9e50833b5";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno2.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlo1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
