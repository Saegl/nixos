{inputs, ...}: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  # `nix-tree` is interesting to explore package dependencies

  programs.nh = {
    enable = true;
    flake = "/home/saegl/projects/nix/nixos";
  };
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"]; # For nixd LSP
}
