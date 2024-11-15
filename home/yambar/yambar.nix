{pkgs, ...}: {
  home.packages = with pkgs; [
    yambar
  ];
  home.file.".config/yambar/config.yml".source = ./config.yml;
}
