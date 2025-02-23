{pkgs, ...}: {
  # search installed fonts with
  # fc-list | grep -i <prefix>
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.iosevka-term
    monocraft
    fantasque-sans-mono
  ];
}
