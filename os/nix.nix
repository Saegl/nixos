{...}: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  programs.nh = {
    enable = true;
    flake = "/home/saegl/projects/nix/nixos";
  };
}
