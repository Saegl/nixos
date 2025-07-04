{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    gnome.enable = lib.mkEnableOption "enable gnome";
  };
  config = lib.mkIf config.gnome.enable {
    # Enable the GNOME Desktop Environment.
    services.xserver.desktopManager.gnome.enable = true;
    services.xserver.displayManager.gdm.enable = true;

    services.displayManager.defaultSession = "gnome-xorg"; # "gnome" | "gnome-xorg"
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany
      # gnome-console # Problems with nautilus without this
    ];
    services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.touchpad]
      click-method='default'
    '';

    programs.dconf.enable = true;
    programs.dconf.profiles = {
      gdm.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              text-scaling-factor = 1.5;
            };
          };
        }
      ];
    };

    environment.systemPackages = with pkgs; [
      # gnome
      gnome-tweaks
    ];
  };
}
