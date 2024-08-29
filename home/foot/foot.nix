{...}: {
  programs.foot.enable = true;
  home.file.".config/foot/foot.ini".source = ./foot.ini;
}
