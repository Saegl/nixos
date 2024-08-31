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
      rye # "cargo" for python
      micromamba # smaller "conda", full OS in your venv
      ruff # python linters impl in rust
      (pkgs.python312.withPackages (ps:
        with ps; [
          ipython
          pytest
          # DAP
          debugpy
          # LSP
          python-lsp-server # pyright for FOSS lovers
          pylsp-mypy
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
