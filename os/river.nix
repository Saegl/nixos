{
  lib,
  config,
  ...
}: {
  options = {
    river.enable = lib.mkEnableOption "enable river";
  };
  config = lib.mkIf config.river.enable {
    programs.river.enable = true;
    programs.river.extraPackages = [];
  };
}
