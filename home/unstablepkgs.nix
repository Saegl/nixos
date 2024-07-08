{pkgs-unstable, ...}: {
  home.packages = with pkgs-unstable; [
    ollama
    protonvpn-gui
  ];
}
