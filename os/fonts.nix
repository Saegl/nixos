{pkgs, ...}: {
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    monocraft
    fantasque-sans-mono
  ];
}
