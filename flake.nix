{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-alien.url = "github:thiagokokada/nix-alien";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-droid.url = "github:nixos/nixpkgs/nixos-24.05";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {...} @ inputs: {
    nixosConfigurations."frostmourne" = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [./frostmourne.nix];
    };
    nixOnDroidConfigurations."nerzhul" = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      pkgs = import inputs.nixpkgs-droid {system = "aarch64-linux";};
      modules = [./nerzhul.nix];
    };
  };
}
