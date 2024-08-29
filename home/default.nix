{pkgs, ...}: {
  imports = [
    ./unstablepkgs.nix
    ./dev.nix
    ./river/river.nix
    ./kitty/kitty.nix
    ./starship/starship.nix
    ./xdg.nix
    ./fuzzel/fuzzel.nix
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
    spotify
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
    # lmstudio
  ];

  programs.zathura.enable = true;

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
      pkg = "nix-shell --run fish -p";

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
    };
  };

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
