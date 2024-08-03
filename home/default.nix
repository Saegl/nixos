{pkgs, ...}: {
  imports = [
    ./unstablepkgs.nix
    ./dev.nix
  ];
  home.username = "saegl";
  home.homeDirectory = "/home/saegl";

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
      ];
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

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
    pastel # colors in cli
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

  programs.zathura.enable = true;

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
      # set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH
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

      # kitty terminal builtin commands
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
