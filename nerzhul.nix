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
    fish
    starship
  ];
  # PATH = "/data/data/com.termux.nix/files/home/.nix-profile/bin:/data/data/com.termux.nix/files/usr/bin";
  # programs.fish.enable = true;
  # programs.fish.shellAliases = {
  #   sw = "nix-on-droid switch --flake ~/nixos/#nerzhul";
  #   sshserver = "'/data/data/com.termux.nix/files/home/.nix-profile/bin/sshd' -dD -f ~/nixos/dotfiles/sshd";
  #   p = "python";
  # };
  # programs.starship.enable = true;
  system.stateVersion = "24.05";
}
