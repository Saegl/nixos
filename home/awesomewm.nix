{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    acpi # battery
    brightnessctl # brightness
    alsa-utils # volume
    pulseaudio # volume
    pavucontrol # gui volume control
    xorg.xev # buttons
    # rofi # menu
    sysstat # cpu usage
    bc # calc for bash commands
  ];

  xresources.extraConfig = ''
    Xft.dpi: 200
  '';
}
