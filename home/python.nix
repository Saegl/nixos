{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    python.enable = lib.mkEnableOption "enable python";
  };
  config = lib.mkIf config.python.enable {
    home.packages = with pkgs; [
      ############### Python tools
      pyright # Python lsp from Microsoft
      micromamba # smaller "conda", full OS in your venv
      ruff # python linters impl in rust
      # uv # python cargo
      pipx # to install newer uv
      (pkgs.python312.withPackages (ps:
        with ps; [
          ipython
          pytest
          # DAP
          debugpy
          # markdown
          grip
        ]))
    ];
    programs.fish.shellAliases = {
      p = "python";
      pt = "pytest";
    };
  };
}
