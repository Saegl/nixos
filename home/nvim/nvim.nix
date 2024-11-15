{
  pkgs,
  config,
  ...
}: {
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
    marksman # markdown
  ];

  # https://jeancharles.quillet.org/posts/2023-02-07-The-home-manager-function-that-changes-everything.html
  # tldr: nix generations slow, let's avoid /nix/store/ for nvim
  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/nix/nixos/home/nvim/config";
}
