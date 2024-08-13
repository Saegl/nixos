{
  lib,
  config,
  pkgs,
  ...
}: {
  options = {
    wayland.enable = lib.mkEnableOption "enable wayland";
  };
  config = lib.mkIf config.wayland.enable {
    environment.systemPackages = with pkgs; [
      wl-clipboard # wayland clipboard tool
      wev # check keyboard key keycode
    ];
  };
}
