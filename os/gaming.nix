{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    gaming.enable = lib.mkEnableOption "enable gaming";
  };
  config = lib.mkIf config.gaming.enable {
    programs.gamemode.enable = true;
    programs.gamemode.enableRenice = true;

    programs.gamescope.enable = true;
    programs.gamescope.capSysNice = true;
    programs.gamescope.args = [
      "--rt" # Real time priority
      # "--prefer-vk-device 10de:25a0" # Use the NVIDIA GeForce RTX 3050 Ti Mobile
      "-W"
      "2560"
      "-H"
      "1600"
      "-r"
      "165"
    ];
    # programs.gamescope.env = {
    #   __NV_PRIME_RENDER_OFFLOAD = "1";
    #   __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    #   __VK_LAYER_NV_optimus = "NVIDIA_only";
    # };

    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.steam.remotePlay.openFirewall = true;
    programs.steam.dedicatedServer.openFirewall = true;
    programs.steam.extraPackages = with pkgs; [
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXScrnSaver
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib
      libkrb5
      keyutils
    ];
  };
}
