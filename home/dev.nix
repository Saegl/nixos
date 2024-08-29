{pkgs, ...}: {
  home.sessionPath = [
    "/home/saegl/.cargo/bin"
  ];

  home.packages = with pkgs; [
    ############### CLI tools
    calc
    unzip
    sqlite
    tmux
    tlrc # "man" but shorter, fork of "tldr"
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
    # elan

    ############### Nix tools
    comma # Use any program without install, just prefix with ","
    nil # Nix LSP
    alejandra # Nix formatter

    ############### C/C++/asm tools
    clang-tools # clangd lsp
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

  # script exec on dir change
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
