{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.sessionPath = [
    "/home/saegl/.cargo/bin"
  ];

  home.file.".config/starship.toml".source = ./dotfiles/starship.toml;
  home.file.".config/kitty/kitty.conf".source = ./dotfiles/kitty.conf;

  home.packages = with pkgs; [
    ############### Code editors
    helix # neovim in rust with weird keymaps and no lua/vimscript
    vscode-fhs # microsoft spyware
    pkgs-unstable.zed-editor # Atom 2024 but fast

    ############### Neovim stuff
    neovide # GUI for neovim
    lua-language-server
    vscode-langservers-extracted # lsp for html/css/json/eslint from vsc*de

    ############### CLI tools
    calc
    unzip
    sqlite
    tmux
    tldr # "man" but shorter
    file # get file info
    cloc # count lines of code
    bat # "cat" but colorful
    ripgrep # "grep" but faster
    fd # "find" but faster
    fzf # fazzy finder
    just # "make" but not for c/c++
    gh # github cli
    tree # print file tree
    tre-command # like "tree" but "tre"

    ############### Python tools
    pyright # Python lsp from Microsoft
    rye # "cargo" for python
    micromamba # smaller "conda", full OS in your venv
    ruff # python linters impl in rust
    pkgs-unstable.ruff-lsp
    (pkgs.python312.withPackages (ps:
      with ps; [
        ipython
        # DAP
        debugpy
        # LSP
        python-lsp-server # pyright for FOSS lovers
        pylsp-mypy
        # markdown
        grip
      ]))

    ############### Terminal
    kitty

    ############### WEB
    caddy # nginx but simpler
    httpie # curl in python
    nmap # hecker stuff
    rustscan # as nmap

    ############### Lua tools
    lua # smol pl
    love # loved game engine

    ############### Rust tools
    rustup

    ############### Lean tools
    elan

    ############### Nix tools
    comma # Use any program without install, just prefix with ","
    nil # Nix LSP
    alejandra # Nix formatter

    ############### C/C++/asm tools
    gcc
    gdb
    nasm
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "Saegl";
    userEmail = "saegl@protonmail.com";
    includes = [
      {
        contents = {
          init.defaultBranch = "main";
        };
      }
    ];
  };

  programs.neovim = {
    package = pkgs-unstable.neovim-unwrapped;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  # script exec on dir change
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
