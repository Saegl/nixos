{config, ...}: {
  imports = [
    ./waybar.nix
  ];

  home.file.".config/fnott/fnott.ini".source = ../dotfiles/fnott/fnott.ini;
  # home.file.".config/foot/foot.ini".source = ../dotfiles/foot/foot.ini;
  home.file.".config/foot".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/nixos/dotfiles/foot";
  # home.file.".config/kitty/kitty.conf".source = ../dotfiles/kitty/kitty.conf;
  home.file.".config/yambar/config.yml".source = ../dotfiles/yambar/config.yml;
  home.file.".unison/shared.prf".source = ../dotfiles/unison/shared.prf;
  home.file.".config/starship.toml".source = ../dotfiles/starship/starship.toml;
  home.file.".config/yazi/yazi.toml".source = ../dotfiles/yazi/yazi.toml;
  home.file.".config/river/init".source = ../dotfiles/river/init;

  home.file.".config/fish/conf.d/init.fish".source = ../dotfiles/fish/init.fish;

  home.file.".local/share/applications/cutechess-xwayland.desktop".source =
    ../dotfiles/desktop/cutechess-xwayland.desktop;

  home.file.".local/share/applications/ghidra-patched.desktop".source =
    ../dotfiles/desktop/ghidra-patched.desktop;

  # https://jeancharles.quillet.org/posts/2023-02-07-The-home-manager-function-that-changes-everything.html
  # tldr: nix generations slow, let's avoid /nix/store/ for nvim
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/nixos/dotfiles/nvim";
  home.file.".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/nixos/dotfiles/niri";
}
