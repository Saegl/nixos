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

# Repoint volta shims to the stable system path (run after upgrading volta)
fixup:
    #!/usr/bin/env bash
    set -euo pipefail
    target=/run/current-system/sw/bin/volta-shim
    test -e "$target" || { echo "ERROR: $target missing (is volta in systemPackages?)"; exit 1; }
    for s in node npm npx pnpm pnpx yarn yarnpkg; do
        ln -sf "$target" "$HOME/.volta/bin/$s"
    done
    echo "volta shims repointed to $target"
