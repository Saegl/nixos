{
  lib,
  config,
  ...
}: {
  options = {
    llm.enable = lib.mkEnableOption "enable llm";
  };
  config = lib.mkIf config.llm.enable {
    services.ollama.enable = true;
  };
}
