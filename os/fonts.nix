{pkgs, ...}: {
  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode"];})
    monocraft
    fantasque-sans-mono
  ];
}
