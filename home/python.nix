{
  lib,
  config,
  ...
}: {
  options = {
    python.enable = lib.mkEnableOption "enable python";
  };
  config = lib.mkIf config.python.enable {
    programs.fish.shellAliases = {
      p = "python";
      pt = "pytest";
    };
  };
}
