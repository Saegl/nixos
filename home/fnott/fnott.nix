{
  lib,
  config,
  ...
}: {
  options = {
    fnott.enable = lib.mkEnableOption "enable fnott";
  };
  config = lib.mkIf config.fnott.enable {
    services.fnott.enable = true;
    home.file.".config/fnott/fnott.ini".source = ./fnott.ini;
  };
}
