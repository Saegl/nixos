{config, ...}: {
  imports = [
    ./waybar.nix
    ./nvim.nix
  ];

  home.file.".config/fnott/fnott.ini".source = ../dotfiles/fnott/fnott.ini;
  home.file.".config/foot/foot.ini".source = ../dotfiles/foot/foot.ini;
  # home.file.".config/kitty/kitty.conf".source = ../dotfiles/kitty/kitty.conf;
  home.file.".config/yambar/config.yml".source = ../dotfiles/yambar/config.yml;
  home.file.".unison/shared.prf".source = ../dotfiles/unison/shared.prf;
  home.file.".config/starship.toml".source = ../dotfiles/starship/starship.toml;
  home.file.".config/yazi/yazi.toml".source = ../dotfiles/yazi/yazi.toml;
  home.file.".config/river/init".source = ../dotfiles/river/init;

  home.file.".config/niri".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/nixos/dotfiles/niri";

  home.file."~/.local/share/applications/org.keepassxc.KeePassXC-xwayland.desktop".source =
    ../dotfiles/desktop/org.keepassxc.KeePassXC-xwayland.desktop;
}
