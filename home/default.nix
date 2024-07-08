{
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    ./unstablepkgs.nix
  ];
  home.username = "saegl";
  home.homeDirectory = "/home/saegl";

  home.sessionPath = [
    "/home/saegl/.cargo/bin"
  ];

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
      ];
    };
  };

  # Dotfiles in .config
  home.file.".config/starship.toml".source = ./dotfiles/starship.toml;
  home.file.".config/kitty/kitty.conf".source = ./dotfiles/kitty.conf;

  home.packages = with pkgs; [
    helix
    vscode-fhs
    pkgs-unstable.zed-editor
    # neovim
    neovide
    lua-language-server
    vscode-langservers-extracted # lsp for html/css/json/eslint from v*code
    pyright
    pkgs-unstable.ruff-lsp
    nil # Nix LSP
    alejandra # Nix formatter
    # dev tools
    calc
    just
    gh
    gcc
    gdb
    nasm
    kitty
    bat
    ripgrep
    fd
    fzf
    unzip
    sqlite
    tree
    tre-command
    cloc
    file
    tmux
    tldr
    comma # Use any program without install
    caddy
    httpie
    nmap
    rustscan
    btop
    lm_sensors
    dconf2nix # Import gnome settings to nix
    ffmpeg
    ## Python tools
    (pkgs.python312.withPackages (ps:
      with ps; [
        # DAP
        debugpy
        # LSP
        python-lsp-server
        pylsp-mypy
      ]))
    rye
    micromamba
    ## Lua tools
    lua
    love
    ## Rust tools
    rustup
    ## Lean tools
    elan
    # virtualization
    qemu
    quickemu
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
    steam
    steam-run
    adoptopenjdk-jre-openj9-bin-8 # for minecraft launcher
    gamescope
    mangohud
    gamemode
    # Graphics
    krita
    aseprite
    gimp
    pastel
    # Chess
    cutechess
    stockfish
    # Regular programs
    firefox
    spotify
    obsidian
    syncthing
    bitwarden
    telegram-desktop
    appimage-run
    qbittorrent
    discord
    anki
    thunderbird
    wineWowPackages.stable
    vlc
    obs-studio
    lmstudio
  ];

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

  programs.neovim = {
    package = pkgs-unstable.neovim-unwrapped;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH
    '';
    shellAliases = {
      setld = "set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH";
      unsetld = "set -u LD_LIBRARY_PATH";
      rebuild = "sudo nixos-rebuild switch";
      wipe-history = "sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system";
      storegc = "sudo nix store gc --debug";
      ":q" = "exit";

      e = "$EDITOR";
      sf = "nvim -c 'Telescope find_files'";
      nv = "neovide";
      nvi = "neovide;exit";

      gs = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      ghb = "gh browse";

      icat = "kitten icat";
      ssh = "kitten ssh";

      vik = "NVIM_APPNAME='kickstart.nvim' nvim";
      vikm = "NVIM_APPNAME='kickstart-modular.nvim' nvim";
      lvim = "NVIM_APPNAME='starter' nvim";
    };
  };

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
