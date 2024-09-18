{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    unison.enable = lib.mkEnableOption "enable unison";
  };
  config = lib.mkIf config.unison.enable {
    home.packages = with pkgs; [
      unison
    ];
    home.file.".unison/shared.prf".source = ./shared.prf;
  };
}
