{...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      # set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH

      # Unbloated login manager
      if status is-login; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
          niri-session
      end
    '';
    # interactiveShellInit = ../dotfiles/fish/init.fish;
    shellAliases = {
      setld = "set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH";
      setldcuda = "set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH $CUDA_PATH/lib $CUDNN_PATH/lib";
      unsetld = "set -u LD_LIBRARY_PATH";
      rebuild = "sudo nixos-rebuild switch";
      wipe-history = "sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system";
      storegc = "sudo nix store gc --debug";
      pkg = "nix-shell --run fish -p";

      # rage quit
      q = "exit";
      Q = "exit";
      ":q" = "exit";
      ":Q" = "exit";

      e = "$EDITOR";
      sf = "nvim -c 'Telescope find_files'";
      gui = "nohup neovide & disown ; exit";

      # python
      p = "python";
      pt = "pytest";

      gs = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      ghb = "gh browse";
    };
  };

  # Fuzzy finder between dirs with "z"
  programs.zoxide.enable = true;

  # script exec on dir change
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # file manager
  programs.yazi.enable = true;
  programs.yazi.enableFishIntegration = true;
}
