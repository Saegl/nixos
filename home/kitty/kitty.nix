{pkgs, ...}: {
  home.file.".config/kitty/kitty.conf".source = ./kitty.conf;
  home.packages = with pkgs; [
    kitty
  ];
  programs.fish = {
    shellAliases = {
      icat = "kitten icat";
      ssh = "kitten ssh";
    };
  };
}
