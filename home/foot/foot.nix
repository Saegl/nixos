{
  lib,
  config,
  ...
}: {
  options = {
    foot.enable = lib.mkEnableOption "enable foot";
  };
  config = lib.mkIf config.foot.enable {
    programs.foot.enable = true;
    home.file.".config/foot/foot.ini".source = ./foot.ini;
  };
}
