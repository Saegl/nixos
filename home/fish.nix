{...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      # set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH
    '';
    shellAliases = {
      setld = "set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH";
      unsetld = "set -u LD_LIBRARY_PATH";
      rebuild = "sudo nixos-rebuild switch";
      wipe-history = "sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system";
      storegc = "sudo nix store gc --debug";
      pkg = "nix-shell --run fish -p";

      ":q" = "exit";

      e = "$EDITOR";
      sf = "nvim -c 'Telescope find_files'";
      nv = "neovide";
      nvi = "neovide;exit";

      gs = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      ghb = "gh browse";
    };
  };

  # Fuzzy finder between dirs with "z"
  programs.zoxide.enable = true;
}
