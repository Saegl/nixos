{
  lib,
  config,
  ...
}: {
  options = {
    x11.enable = lib.mkEnableOption "enable x11";
  };
  config = lib.mkIf config.x11.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Configure keymap in X11
    services.xserver.xkb.layout = "us,ru";
    services.xserver.xkb.options = "grp:alt_shift_toggle";
  };
}
