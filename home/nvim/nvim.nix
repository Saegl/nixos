{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  home.packages = with pkgs; [
    # LSPS
    lua-language-server
    vscode-langservers-extracted # html/css/json/eslint
    ltex-ls # grammar checker (markdown, latex)
    ruff-lsp # python linter
  ];
}
