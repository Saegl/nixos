{pkgs, ...}: {
  # search installed fonts with
  # fc-list | grep -i <prefix>
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    monocraft
    fantasque-sans-mono
  ];
}
