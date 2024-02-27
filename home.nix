{ config, pkgs, ... }:
{
  home.username = "saegl";
  home.homeDirectory = "/home/saegl";
  #home.pointerCursor = {
  #  gtk.enable = true;
  #  package = pkgs.bibata-cursors;
  #  name = "Bibata-Modern-Classic";
  #  size = 16;
  #};
  # gtk = {
  #   enable = true;
  #   theme = {
  #     package = pkgs.flat-remix-gtk;
  #     name = "Flat-Remix-GTK-Grey-Darkest";
  #   };
  #   iconTheme = {
  #     package = pkgs.libsForQt5.breeze-icons;
  #     name = "breeze-dark";
  #   };
  #   font = {
  #    name = "Sans";
  #    size = 11;
  #  };
  #  gtk3.extraConfig = {
  #    Settings = ''
  #      gtk-application-prefer-dark-theme=1
  #    '';
  #  };
  #  gtk4.extraConfig = {
  #    Settings = ''
  #      gtk-application-prefer-dark-theme=1
  #    '';
  #  };
  #};

  #dconf = {
  #  enable = true;
  #  settings = {
  #    "org/gnome/desktop/interface" = {
  #      color-scheme = "prefer-dark";
  #    };
  #  };
  #};
  
  # Examples
  # link file 
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link dir
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # link from string 
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  home.packages = with pkgs; [
    # neovim 
    lua-language-server
    pyright
    # dev tools
    gh
    python312
    micromamba
    gcc
    kitty
    bat
    ripgrep
    fd
    sqlite
    cloc
    file
    # gaming
    lutris
    steam
    steam-run
    adoptopenjdk-jre-openj9-bin-8  # for minecraft launcher 
    gamescope
    mangohud
    gamemode
    # Regular programs
    firefox
    spotify
    obsidian
    syncthing
    bitwarden
    telegram-desktop
    gimp
    appimage-run
    qbittorrent
    cutechess
    stockfish
    # kriat QT_SCALE_FACTOR=1.8
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Saegl";
    userEmail = "saegl@protonmail.com";
    includes = [{
      contents = {
        init.defaultBranch = "main";
      };
    }];
  };

  programs.neovim = {
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

  programs.fish = {
    enable = true;
    interactiveShellInit = "set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH";
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch";
      wipe-history = "sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system";
      gc = "sudo nix store gc --debug";
    };
  };

  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
