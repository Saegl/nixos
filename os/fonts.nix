{pkgs, ...}: {
  # search installed fonts with
  # fc-list | grep -i <prefix>
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.iosevka-term
    nerd-fonts.blex-mono
    nerd-fonts.jetbrains-mono
    monocraft
    fantasque-sans-mono
  ];
  # symlink fonts to /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;
}
