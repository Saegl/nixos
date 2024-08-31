{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    kitty.enable = lib.mkEnableOption "enable kitty";
  };
  config = lib.mkIf config.kitty.enable {
    home.file.".config/kitty/kitty.conf".source = ./kitty.conf;
    home.packages = with pkgs; [
      kitty
    ];
    programs.fish = {
      shellAliases = {
        icat = "kitten icat";
        kssh = "kitten ssh";
      };
    };
  };
}
