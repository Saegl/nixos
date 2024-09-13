{pkgs, ...}: {
  user.shell = "${pkgs.fish}/bin/fish";
  environment.packages = with pkgs; [
    which
    neovim
    neofetch
    git
    python312
    openssh
    unison
    unixtools.ifconfig
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
      home.sessionVariables = {
        PATH = "/data/data/com.termux.nix/files/home/.nix-profile/bin:/data/data/com.termux.nix/files/usr/bin";
      };
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

      programs.starship.enable = true;
    };
  };
}
