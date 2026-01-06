# Rebuild NixOS system
sw:
    nh os switch

# Clean old generations and garbage collect
clean:
    nh clean all

# Update flake inputs
up:
    nix flake update --commit-lock-file --impure \
        --override-input nixpkgs github:NixOS/nixpkgs/$(curl -L https://channels.nixos.org/nixpkgs-unstable/git-revision)
