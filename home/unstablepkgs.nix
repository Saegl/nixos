{pkgs-unstable, ...}: {
  home.packages = with pkgs-unstable; [
    protonvpn-gui
  ];
}
