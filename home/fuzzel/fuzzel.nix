{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    fuzzel.enable = lib.mkEnableOption "enable fuzzel";
  };
  config = lib.mkIf config.fuzzel.enable {
    home.packages = with pkgs; [
      fuzzel # app launcher + fuzzy finder
      bemoji # emoji
      cliphist # clipboard
      (
        pkgs.writers.writeFishBin "powermenu" {} (builtins.readFile ./powermenu.fish)
      )
    ];
  };
}
