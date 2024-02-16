{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true; # TODO: what this command do?
  networking.hostName = "frostmourne";
  time.timeZone = "Asia/Almaty";
  i18n.defaultLocale = "en_US.UTF-8";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # wifi
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;
  # networking.wireless.userControlled.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  hardware.opengl.driSupport32Bit = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  #   [org.gnome.desktop.peripherals.touchpad]
  #   click-method='default'
  # '';

  # programs.hyprland.enable = true;
  # services.xserver.windowManager.openbox.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.displayManager.sddm = {
  #   enable = true;
  #   wayland.enable = true;
  # };
  services.xserver.displayManager.startx.enable = true;
  services.xserver.windowManager.qtile = {
    enable = true;
    backend = "wayland";
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "grp:alt_shift_toggle";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  services.blueman.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.saegl = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
    ];
    packages = with pkgs; [
    ];
    createHome = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"  # TODO Unfortunately needed for obsidian, remove when fixed
  ];

  services.asusd.enable = true;
  environment.systemPackages = with pkgs; [
    # basic
    wget
    htop
    killall
    asusctl
    # hyprland
    wl-clipboard  # nvim clipboard not gonna work without this
    waybar
    hyprpaper
    font-awesome
    pavucontrol
    fuzzel
    wev # check keycode
    # qtile
    alsa-utils  # volume
  ];

  fonts.packages = with pkgs; [
    nerdfonts
  ];

  # NEVER CHANGE
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}

