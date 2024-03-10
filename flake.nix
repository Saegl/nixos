{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
    };
  in {
    nixosConfigurations."frostmourne" = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs pkgs-unstable;};
      modules = [
        ./hosts/frostmourne/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.saegl = import ./home;
          home-manager.extraSpecialArgs = {inherit pkgs-unstable;};
        }
      ];
    };
  };
}
