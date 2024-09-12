{pkgs, ...}: {
  user.shell = "${pkgs.fish}/bin/fish";
  environment.packages = with pkgs; [
    neovim
    neofetch
    git
    python312
  ];
  system.stateVersion = "24.05";
  home-manager = {
    useGlobalPkgs = true;

    config = {
      config,
      lib,
      pkgs,
      ...
    }: {
      home.stateVersion = "24.05";
      programs.fish.enable = true;
      programs.fish.shellAliases = {
        sw = "nix-on-droid switch --flake ~/nixos/#nerzhul";
        p = "python";
      };
      programs.zoxide.enable = true;

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
  };
}
